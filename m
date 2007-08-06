From: Thomas Klein <osstklei@de.ibm.com>
Subject: [RESEND][PATCH 3/3] ehea: Eliminated some compiler warnings
Date: Mon, 6 Aug 2007 13:55:44 +0200
Message-ID: <200708061355.45462.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:37770 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763583AbXHFLzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 07:55:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed wrongly casted pointers

Signed-off-by: Thomas Klein <tklein@de.ibm.com>

---
 drivers/net/ehea/ehea_main.c |   25 ++++++++++---------------
 1 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 36ca322..9756211 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1326,7 +1326,6 @@ static void write_swqe2_TSO(struct sk_buff *skb,
 	u8 *imm_data = &swqe->u.immdata_desc.immediate_data[0];
 	int skb_data_size = skb->len - skb->data_len;
 	int headersize;
-	u64 tmp_addr;
 
 	/* Packet is TCP with TSO enabled */
 	swqe->tx_control |= EHEA_SWQE_TSO;
@@ -1347,9 +1346,8 @@ static void write_swqe2_TSO(struct sk_buff *skb,
 			/* set sg1entry data */
 			sg1entry->l_key = lkey;
 			sg1entry->len = skb_data_size - headersize;
-
-			tmp_addr = (u64)(skb->data + headersize);
-			sg1entry->vaddr = ehea_map_vaddr(tmp_addr);
+			sg1entry->vaddr =
+				ehea_map_vaddr(skb->data + headersize);
 			swqe->descriptors++;
 		}
 	} else
@@ -1362,7 +1360,6 @@ static void write_swqe2_nonTSO(struct sk_buff *skb,
 	int skb_data_size = skb->len - skb->data_len;
 	u8 *imm_data = &swqe->u.immdata_desc.immediate_data[0];
 	struct ehea_vsgentry *sg1entry = &swqe->u.immdata_desc.sg_entry;
-	u64 tmp_addr;
 
 	/* Packet is any nonTSO type
 	 *
@@ -1379,8 +1376,8 @@ static void write_swqe2_nonTSO(struct sk_buff *skb,
 			/* copy sg1entry data */
 			sg1entry->l_key = lkey;
 			sg1entry->len = skb_data_size - SWQE2_MAX_IMM;
-			tmp_addr = (u64)(skb->data + SWQE2_MAX_IMM);
-			sg1entry->vaddr = ehea_map_vaddr(tmp_addr);
+			sg1entry->vaddr =
+				ehea_map_vaddr(skb->data + SWQE2_MAX_IMM);
 			swqe->descriptors++;
 		}
 	} else {
@@ -1395,7 +1392,6 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 	struct ehea_vsgentry *sg_list, *sg1entry, *sgentry;
 	skb_frag_t *frag;
 	int nfrags, sg1entry_contains_frag_data, i;
-	u64 tmp_addr;
 
 	nfrags = skb_shinfo(skb)->nr_frags;
 	sg1entry = &swqe->u.immdata_desc.sg_entry;
@@ -1417,9 +1413,9 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 			/* copy sg1entry data */
 			sg1entry->l_key = lkey;
 			sg1entry->len = frag->size;
-			tmp_addr =  (u64)(page_address(frag->page)
-					  + frag->page_offset);
-			sg1entry->vaddr = ehea_map_vaddr(tmp_addr);
+			sg1entry->vaddr =
+				ehea_map_vaddr(page_address(frag->page)
+					       + frag->page_offset);
 			swqe->descriptors++;
 			sg1entry_contains_frag_data = 1;
 		}
@@ -1431,10 +1427,9 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 
 			sgentry->l_key = lkey;
 			sgentry->len = frag->size;
-
-			tmp_addr = (u64)(page_address(frag->page)
-					 + frag->page_offset);
-			sgentry->vaddr = ehea_map_vaddr(tmp_addr);
+			sgentry->vaddr =
+				ehea_map_vaddr(page_address(frag->page)
+					       + frag->page_offset);
 			swqe->descriptors++;
 		}
 	}
-- 
1.5.2


