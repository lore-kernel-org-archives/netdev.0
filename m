From: Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 2/4] cxgb4: Export symbols required by cxgb4i for ipv6 support and required defines
Date: Tue, 15 Jul 2014 19:55:51 -0700
Message-ID: <1405479353-2289-3-git-send-email-anish@chelsio.com>
References: <1405479353-2289-1-git-send-email-anish@chelsio.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org, jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405479353-2289-1-git-send-email-anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 10 ++++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |  4 ++++
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |  2 ++
 3 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 2b438bd68c73..07c726677fdd 100644
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
index 8f60851b75ad..5de3a70b8376 100644
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
