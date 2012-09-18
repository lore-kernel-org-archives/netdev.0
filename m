From: Jamie Gloudon <jamie.gloudon@gmail.com>
Subject: BUG: TCPDUMP invalid cksum persists after disabling TCP cksum offload
Date: Tue, 18 Sep 2012 17:14:23 -0400
Message-ID: <20120918211423.GA19115@darkstar>
References: <20120918193208.GA19030@darkstar>
 <1347998905.2685.29.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:40531 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755315Ab2IRVOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 17:14:30 -0400
Received: by qaas11 with SMTP id s11so420246qaa.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 14:14:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1347998905.2685.29.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
   I am seeing that tx checksum offload appears to be still running after disabling the feature with ethtool. I'm using kernel 3.6.0-rc6 and the latest ethtool from the git repo. 
 
The default settings on my e1000e NIC:
# ethtool -k eth1 | grep ': on'
 rx-checksumming: on
 tx-checksumming: on
        tx-checksum-ip-generic: on
 scatter-gather: on
         tx-scatter-gather: on
 tcp-segmentation-offload: on
         tx-tcp-segmentation: on
         tx-tcp6-segmentation: on
 generic-segmentation-offload: on
 generic-receive-offload: on
 rx-vlan-offload: on
 tx-vlan-offload: on
 receive-hashing: on
 highdma: on [fixed]
 rx-vlan-filter: on [fixed]
 tx-nocache-copy: on
 
The results after disabling tcp cksum offload feature:
# ethtool -K eth1 tx off
Actual changes:
 tx-checksumming: off
         tx-checksum-ip-generic: off
 scatter-gather: off
         tx-scatter-gather: off [requested on]
 tcp-segmentation-offload: off
         tx-tcp-segmentation: off [requested on]
         tx-tcp6-segmentation: off [requested on]
 generic-segmentation-offload: off [requested on]
 
However, in tcpdump, I'm still observing incorrect tcp checksum:
14:44:38.838711 IP (tos 0x10, ttl 64, id 45798, offset 0, flags [DF], proto TCP
(6), length 60)
     1.1.1.2.59748 > 1.1.1.1.23: Flags [S], cksum 0x0433 (incorrect -> 0x4137), seq 318222122, win 14600, options [mss 1460,sackOK,TS val 5447116 ecr 0,nop,wscale 7], length 0
 
Is this behaviour valid? I'm quite baffled.

Regards,
Jamie Gloudon
