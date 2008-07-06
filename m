From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 02/06]: e1000e: don't truncate VLAN TCI with VLAN stripping
Date: Mon, 07 Jul 2008 00:48:10 +0200
Message-ID: <48714BAA.2010802@trash.net>
References: <487148E0.5040407@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050206070007040605000609"
Cc: Jeff Garzik <jeff@garzik.org>, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	john.ronciak@intel.com
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42101 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756163AbYGFWyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 18:54:12 -0400
In-Reply-To: <487148E0.5040407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050206070007040605000609
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit




--------------050206070007040605000609
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

e1000e: don't truncate VLAN TCI with VLAN stripping

The vlan_hwaccel_{rx,receive_skb} functions expect the full TCI field
for priority mappings, don't truncate the upper 4 bits.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit aef20146b65b227a9eba0fa84bd1bd36fbdd7805
tree 0f064a48f2c2191b06f061877973cd0613dc718c
parent 4e95de3d2639cf46d4c88556f36585647ee96912
author Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 00:25:13 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 00:25:13 +0200

 drivers/net/e1000e/netdev.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index acdd616..80592bd 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -98,8 +98,7 @@ static void e1000_receive_skb(struct e1000_adapter *adapter,
 
 	if (adapter->vlgrp && (status & E1000_RXD_STAT_VP))
 		vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-					 le16_to_cpu(vlan) &
-					 E1000_RXD_SPC_VLAN_MASK);
+					 le16_to_cpu(vlan));
 	else
 		netif_receive_skb(skb);
 


--------------050206070007040605000609--
