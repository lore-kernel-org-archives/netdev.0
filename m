From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH 6/6] connector: replace obsolete NLMSG_* with type safe nlmsg_*
Date: Thu, 28 Mar 2013 00:54:56 +0800
Message-ID: <1364403296-32880-1-git-send-email-honkiko@gmail.com>
Cc: zbr@ioremap.net, netdev@vger.kernel.org, davem@davemloft.net,
	tgraf@suug.ch
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 drivers/connector/connector.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index f1b7e24..6ecfa75 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -23,7 +23,7 @@
 #include <linux/module.h>
 #include <linux/list.h>
 #include <linux/skbuff.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/moduleparam.h>
 #include <linux/connector.h>
 #include <linux/slab.h>
@@ -95,13 +95,13 @@ int cn_netlink_send(struct cn_msg *msg, u32 __group, gfp_t gfp_mask)
 	if (!netlink_has_listeners(dev->nls, group))
 		return -ESRCH;
 
-	size = NLMSG_SPACE(sizeof(*msg) + msg->len);
+	size = sizeof(*msg) + msg->len;
 
-	skb = alloc_skb(size, gfp_mask);
+	skb = nlmsg_new(size, gfp_mask);
 	if (!skb)
 		return -ENOMEM;
 
-	nlh = nlmsg_put(skb, 0, msg->seq, NLMSG_DONE, size - sizeof(*nlh), 0);
+	nlh = nlmsg_put(skb, 0, msg->seq, NLMSG_DONE, size, 0);
 	if (!nlh) {
 		kfree_skb(skb);
 		return -EMSGSIZE;
@@ -124,7 +124,7 @@ static int cn_call_callback(struct sk_buff *skb)
 {
 	struct cn_callback_entry *i, *cbq = NULL;
 	struct cn_dev *dev = &cdev;
-	struct cn_msg *msg = NLMSG_DATA(nlmsg_hdr(skb));
+	struct cn_msg *msg = nlmsg_data(nlmsg_hdr(skb));
 	struct netlink_skb_parms *nsp = &NETLINK_CB(skb);
 	int err = -ENODEV;
 
@@ -162,7 +162,7 @@ static void cn_rx_skb(struct sk_buff *__skb)
 
 	skb = skb_get(__skb);
 
-	if (skb->len >= NLMSG_SPACE(0)) {
+	if (skb->len >= NLMSG_HDRLEN) {
 		nlh = nlmsg_hdr(skb);
 
 		if (nlh->nlmsg_len < sizeof(struct cn_msg) ||
-- 
1.7.10.4
