From: frank.blaschka@de.ibm.com
Subject: [patch 1/1] qeth: fix 2.6.27 build
Date: Mon, 21 Jul 2008 13:54:29 +0200
Message-ID: <20080721115507.647845000@de.ibm.com>
References: <20080721115428.005485000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	bunk@kernel.org, kaber@trash.net
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:36276 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668AbYGUL4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 07:56:09 -0400
Content-Disposition: inline; filename=qeth_fix_build.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Remove obsolete setting of the VLAN magic. This will fix the build
error introduced by Commit 6aa895b047720f71ec4eb11452f7c3ce8426941f
(vlan: Don't store VLAN tag in cb)

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c |    1 -
 1 file changed, 1 deletion(-)

Index: git_linus/drivers/s390/net/qeth_l3_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_l3_main.c	2008-07-21 13:35:25.000000000 +0200
+++ git_linus/drivers/s390/net/qeth_l3_main.c	2008-07-21 13:37:12.000000000 +0200
@@ -2651,7 +2651,6 @@
 			tag = (u16 *)(new_skb->data + 12);
 			*tag = __constant_htons(ETH_P_8021Q);
 			*(tag + 1) = htons(vlan_tx_tag_get(new_skb));
-			VLAN_TX_SKB_CB(new_skb)->magic = 0;
 		}
 	}
 

-- 
