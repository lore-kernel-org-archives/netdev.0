From: Joe Perches <joe@perches.com>
Subject: [PATCH] - [2/15] - remove defconfig ptr comparisons to 0 -
	drivers/net
Date: Tue, 13 Nov 2007 18:04:50 -0800
Message-ID: <1195005890.5163.88.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Chan <mchan@broadcom.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	netdev <netdev@vger.kernel.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4742 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761251AbXKNCEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 21:04:52 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove defconfig ptr comparison to 0

Remove sparse warning: Using plain integer as NULL pointer

Signed-off-by: Joe Perches <joe@perches.com>

---

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index da767d3..cec3cb4 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2495,7 +2495,7 @@ reuse_rx:
 		}
 
 #ifdef BCM_VLAN
-		if ((status & L2_FHDR_STATUS_L2_VLAN_TAG) && (bp->vlgrp != 0)) {
+		if ((status & L2_FHDR_STATUS_L2_VLAN_TAG) && bp->vlgrp) {
 			vlan_hwaccel_receive_skb(skb, bp->vlgrp,
 				rx_hdr->l2_fhdr_vlan_tag);
 		}
@@ -5134,7 +5134,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		vlan_tag_flags |= TX_BD_FLAGS_TCP_UDP_CKSUM;
 	}
 
-	if (bp->vlgrp != 0 && vlan_tx_tag_present(skb)) {
+	if (bp->vlgrp && vlan_tx_tag_present(skb)) {
 		vlan_tag_flags |=
 			(TX_BD_FLAGS_VLAN_TAG | (vlan_tx_tag_get(skb) << 16));
 	}
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4942f7d..b189c47 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12576,7 +12576,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		tg3reg_len = pci_resource_len(pdev, 2);
 
 		tp->aperegs = ioremap_nocache(tg3reg_base, tg3reg_len);
-		if (tp->aperegs == 0UL) {
+		if (!tp->aperegs) {
 			printk(KERN_ERR PFX "Cannot map APE registers, "
 			       "aborting.\n");
 			err = -ENOMEM;


