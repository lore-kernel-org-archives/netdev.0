From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 01/06]: e1000: don't truncate VLAN TCI with VLAN stripping
Date: Mon, 07 Jul 2008 00:48:08 +0200
Message-ID: <48714BA8.5070708@trash.net>
References: <487148E0.5040407@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090201080208030706050306"
Cc: Jeff Garzik <jeff@garzik.org>, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	john.ronciak@intel.com
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42097 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755895AbYGFWyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 18:54:10 -0400
In-Reply-To: <487148E0.5040407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090201080208030706050306
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit




--------------090201080208030706050306
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

e1000: don't truncate VLAN TCI with VLAN stripping

The vlan_hwaccel_{rx,receive_skb} functions expect the full TCI field
for priority mappings, don't truncate the upper 4 bits.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 4e95de3d2639cf46d4c88556f36585647ee96912
tree 197487137f449c7d88fc77f4147a2d22bb8382e4
parent aee18a8cf28808b7302ef698d77fa73883e60f1b
author Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 00:25:13 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 00:25:13 +0200

 drivers/net/e1000/e1000_main.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 311ca26..7aa458f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4277,8 +4277,7 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		if (unlikely(adapter->vlgrp &&
 			    (status & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-						 le16_to_cpu(rx_desc->special) &
-						 E1000_RXD_SPC_VLAN_MASK);
+						 le16_to_cpu(rx_desc->special));
 		} else {
 			netif_receive_skb(skb);
 		}
@@ -4286,8 +4285,7 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		if (unlikely(adapter->vlgrp &&
 			    (status & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
-					le16_to_cpu(rx_desc->special) &
-					E1000_RXD_SPC_VLAN_MASK);
+					le16_to_cpu(rx_desc->special));
 		} else {
 			netif_rx(skb);
 		}
@@ -4464,16 +4462,14 @@ copydone:
 #ifdef CONFIG_E1000_NAPI
 		if (unlikely(adapter->vlgrp && (staterr & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->wb.middle.vlan) &
-				E1000_RXD_SPC_VLAN_MASK);
+				le16_to_cpu(rx_desc->wb.middle.vlan));
 		} else {
 			netif_receive_skb(skb);
 		}
 #else /* CONFIG_E1000_NAPI */
 		if (unlikely(adapter->vlgrp && (staterr & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->wb.middle.vlan) &
-				E1000_RXD_SPC_VLAN_MASK);
+				le16_to_cpu(rx_desc->wb.middle.vlan));
 		} else {
 			netif_rx(skb);
 		}


--------------090201080208030706050306--
