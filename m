From: Erik Hugne <erik.hugne@ericsson.com>
Subject: be2net: GRO for non-inet protocols
Date: Fri, 5 Apr 2013 15:20:07 +0200
Message-ID: <20130405132007.GF7551@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:46882 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161369Ab3DENZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 09:25:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm adding GRO support for the TIPC protocol and
tried to test it on a pair of HP G7 blades with 
Emulex Corporation OneConnect 10Gb NIC (be3) (rev 01) NICs.

However, my GRO callback is never invoked on this setup, and 
i suspect the be2net driver is to blame.
I had a brief look at the driver, first suspecting that the
do_gro check only passed for inet protocols (tcpf must be set 
in the be_rx_compl_info struct).
However, removing this check did not change the behavior.

#ethtool -i eth1
driver: be2net
version: 4.4.161.0s
firmware-version: 4.1.450.7
bus-info: 0000:02:00.1
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: no

It works as expected on another setup with with Intel NIC's/e1000 driver.

//E
