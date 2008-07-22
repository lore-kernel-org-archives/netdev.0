From: frank.blaschka@de.ibm.com
Subject: [patch 1/1] qeth: fix build error caused by VLAN changes
Date: Tue, 22 Jul 2008 09:39:25 +0200
Message-ID: <20080722074014.988096000@de.ibm.com>
References: <20080722073924.165257000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	bunk@kernel.org, kaber@trash.net
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:63054 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbYGVHl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 03:41:27 -0400
Content-Disposition: inline; filename=qeth_fix_build.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk reports this build error:

CC      drivers/s390/net/qeth_l3_main.o
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c:
In function 'qeth_l3_hard_start_xmit':
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c:
2654: error: implicit declaration of function 'VLAN_TX_SKB_CB'
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c:
2654: error: invalid type argument of '->' (have 'int')
make[3]: *** [drivers/s390/net/qeth_l3_main.o] Error 1

The intention of the driver appears to be to invalidate the VLAN tag.
Change it to set skb->vlan_tci to zero, which has the same effect.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: git_linus/drivers/s390/net/qeth_l3_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_l3_main.c	2008-07-22 09:25:13.000000000 +0200
+++ git_linus/drivers/s390/net/qeth_l3_main.c	2008-07-22 09:27:04.000000000 +0200
@@ -2651,7 +2651,7 @@
 			tag = (u16 *)(new_skb->data + 12);
 			*tag = __constant_htons(ETH_P_8021Q);
 			*(tag + 1) = htons(vlan_tx_tag_get(new_skb));
-			VLAN_TX_SKB_CB(new_skb)->magic = 0;
+			new_skb->vlan_tci = 0;
 		}
 	}
 

-- 
