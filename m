From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next v2 2/4] cxgb4: Export symbols required by cxgb4i for ipv6 support and required defines
Date: Thu, 17 Jul 2014 00:18:16 -0700
Message-ID: <1405581498-28092-3-git-send-email-anish@chelsio.com>
References: <1405581498-28092-1-git-send-email-anish@chelsio.com>
Cc: linux-rdma@vger.kernel.org, linux-scsi@vger.kernel.org,
	davem@davemloft.net, roland@purestorage.com, hch@infradead.org,
	michaelc@cs.wisc.edu, jbottomley@parallels.com, kxie@chelsio.com,
	leedom@chelsio.com, hariprasad@chelsio.com,
	swise@opengridcomputing.com, Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:54183
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753810AbaGQHUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 03:20:48 -0400
In-Reply-To: <1405581498-28092-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 10 ++++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |  4 ++++
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |  2 ++
 3 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 9c7e4f0a7683..8b46534b06c1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3445,8 +3445,8 @@ static int tid_init(struct tid_info *t)
 	return 0;
 }
 
-static int cxgb4_clip_get(const struct net_device *dev,
-			  const struct in6_addr *lip)
+int cxgb4_clip_get(const struct net_device *dev,
+		   const struct in6_addr *lip)
 {
 	struct adapter *adap;
 	struct fw_clip_cmd c;
@@ -3460,9 +3460,10 @@ static int cxgb4_clip_get(const struct net_device *dev,
 	c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
 	return t4_wr_mbox_meat(adap, adap->mbox, &c, sizeof(c), &c, false);
 }
+EXPORT_SYMBOL(cxgb4_clip_get);
 
-static int cxgb4_clip_release(const struct net_device *dev,
-			      const struct in6_addr *lip)
+int cxgb4_clip_release(const struct net_device *dev,
+		       const struct in6_addr *lip)
 {
 	struct adapter *adap;
 	struct fw_clip_cmd c;
@@ -3476,6 +3477,7 @@ static int cxgb4_clip_release(const struct net_device *dev,
 	c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
 	return t4_wr_mbox_meat(adap, adap->mbox, &c, sizeof(c), &c, false);
 }
+EXPORT_SYMBOL(cxgb4_clip_release);
 
 /**
  *	cxgb4_create_server - create an IP server
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 79a84de1d204..1366ba620c87 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -172,6 +172,10 @@ int cxgb4_create_server_filter(const struct net_device *dev, unsigned int stid,
 			       unsigned char port, unsigned char mask);
 int cxgb4_remove_server_filter(const struct net_device *dev, unsigned int stid,
 			       unsigned int queue, bool ipv6);
+int cxgb4_clip_get(const struct net_device *dev, const struct in6_addr *lip);
+int cxgb4_clip_release(const struct net_device *dev,
+		       const struct in6_addr *lip);
+
 static inline void set_wr_txq(struct sk_buff *skb, int prio, int queue)
 {
 	skb_set_queue_mapping(skb, (queue << 1) | prio);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 64006327df83..0259feeab1b3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -270,6 +270,8 @@ struct cpl_pass_accept_rpl {
 #define RX_COALESCE_VALID(x) ((x) << 11)
 #define RX_COALESCE(x)       ((x) << 12)
 #define PACE(x)	      ((x) << 16)
+#define RX_FC_VALID	     ((1U) << 19)
+#define RX_FC_DISABLE	     ((1U) << 20)
 #define TX_QUEUE(x)          ((x) << 23)
 #define RX_CHANNEL(x)        ((x) << 26)
 #define CCTRL_ECN(x)         ((x) << 27)
-- 
2.0.1
