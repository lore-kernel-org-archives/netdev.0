From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [net-next PATCH v3 4/6] macvtap: adjust macvtap_skb_to_vnet_hdr() to be void
Date: Fri,  6 Dec 2013 14:19:40 +0800
Message-ID: <1386310782-9378-5-git-send-email-zwu.kernel@gmail.com>
References: <1386310782-9378-1-git-send-email-zwu.kernel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386310782-9378-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/macvtap.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index d271fb4..f599c47 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -588,7 +588,7 @@ static int macvtap_skb_from_vnet_hdr(struct sk_buff *skb,
 	return 0;
 }
 
-static int macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
+static void macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
 				   struct virtio_net_hdr *vnet_hdr)
 {
 	memset(vnet_hdr, 0, sizeof(*vnet_hdr));
@@ -619,8 +619,6 @@ static int macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
 	} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
 		vnet_hdr->flags = VIRTIO_NET_HDR_F_DATA_VALID;
 	} /* else everything is zero */
-
-	return 0;
 }
 
 /* Get packet from user space buffer */
@@ -778,7 +776,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 		if ((len -= vnet_hdr_len) < 0)
 			return -EINVAL;
 
-		ret = macvtap_skb_to_vnet_hdr(skb, &vnet_hdr);
+		macvtap_skb_to_vnet_hdr(skb, &vnet_hdr);
 
 		if (memcpy_toiovecend(iv, (void *)&vnet_hdr, 0, sizeof(vnet_hdr)))
 			return -EFAULT;
-- 
1.7.6.5
