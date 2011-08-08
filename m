From: frank.blaschka@de.ibm.com
Subject: [patch 01/13] [PATCH] qeth: l3 ipv6 vlan not working on shared OSA chpid
Date: Mon, 08 Aug 2011 13:33:47 +0200
Message-ID: <20110808113515.381926973@de.ibm.com>
References: <20110808113346.516293249@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([194.196.100.163]:57456 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753175Ab1HHLfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 07:35:31 -0400
Content-Disposition: inline; filename=qeth_l3_ipv6_vlan.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

In layer 3 mode IPv6 over VLAN does not work on newer OSA  levels in
case the sender and receiver run on the same (shared) OSA adapter.
Keep vlan info in the skb so the qdio header is filled with the
required vlan tag.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c |    1 -
 1 file changed, 1 deletion(-)

--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2993,7 +2993,6 @@ static int qeth_l3_hard_start_xmit(struc
 			tag = (u16 *)(new_skb->data + 12);
 			*tag = __constant_htons(ETH_P_8021Q);
 			*(tag + 1) = htons(vlan_tx_tag_get(new_skb));
-			new_skb->vlan_tci = 0;
 		}
 	}
 

