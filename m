From: frank.blaschka@de.ibm.com
Subject: [patch 0/2] vlan, qeth: neigh_setup
Date: Wed, 07 Jan 2009 13:15:50 +0100
Message-ID: <20090107121550.878339000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:62576 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbZAGMRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 07:17:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

the qeth_l3 driver uses the neigh_setup function to turn off ARP for
IPv4. But since the vlan driver does not support a neigh_setup
function I had to add an ugly hack to the qeth_l3_add_vid function
(set the neigh_setup function of the vlan device to the function of
the real device). With the new net_device_ops this hack will not work
any longer so I want to add neigh_setup to the vlan driver.

Following patches add the neigh_setup to vlan and change qeth to
use the net_device_ops. Do you see any problems?

Or is there a better way to turn off ARP for IPv4 (we still need
neighbour solicitation for IPv6 so IFF_NOARP is no option)?

Thanks,
        Frank

-- 
