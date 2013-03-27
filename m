From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH 4/6] gdm72xx: replace obsolete NLMSG_* with type safe nlmsg_*
Date: Thu, 28 Mar 2013 00:52:17 +0800
Message-ID: <1364403137-32806-1-git-send-email-honkiko@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, tgraf@suug.ch
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 drivers/staging/gdm72xx/netlink_k.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/gdm72xx/netlink_k.c b/drivers/staging/gdm72xx/netlink_k.c
index 52c25ba..c1239aa 100644
--- a/drivers/staging/gdm72xx/netlink_k.c
+++ b/drivers/staging/gdm72xx/netlink_k.c
@@ -15,7 +15,7 @@
 
 #include <linux/module.h>
 #include <linux/etherdevice.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <asm/byteorder.h>
 #include <net/sock.h>
 
@@ -25,12 +25,12 @@
 
 #define ND_MAX_GROUP			30
 #define ND_IFINDEX_LEN			sizeof(int)
-#define ND_NLMSG_SPACE(len)		(NLMSG_SPACE(len) + ND_IFINDEX_LEN)
+#define ND_NLMSG_SPACE(len)		(nlmsg_total_size(len) + ND_IFINDEX_LEN)
 #define ND_NLMSG_DATA(nlh) \
-	((void *)((char *)NLMSG_DATA(nlh) + ND_IFINDEX_LEN))
+	((void *)((char *)nlmsg_data(nlh) + ND_IFINDEX_LEN))
 #define ND_NLMSG_S_LEN(len)		(len+ND_IFINDEX_LEN)
 #define ND_NLMSG_R_LEN(nlh)		(nlh->nlmsg_len-ND_IFINDEX_LEN)
-#define ND_NLMSG_IFIDX(nlh)		NLMSG_DATA(nlh)
+#define ND_NLMSG_IFIDX(nlh)		nlmsg_data(nlh)
 #define ND_MAX_MSG_LEN			8096
 
 #if defined(DEFINE_MUTEX)
@@ -51,7 +51,7 @@ static void netlink_rcv_cb(struct sk_buff *skb)
 	void *msg;
 	int ifindex;
 
-	if (skb->len >= NLMSG_SPACE(0)) {
+	if (skb->len >= NLMSG_HDRLEN) {
 		nlh = (struct nlmsghdr *)skb->data;
 
 		if (skb->len < nlh->nlmsg_len ||
@@ -124,7 +124,7 @@ int netlink_send(struct sock *sock, int group, u16 type, void *msg, int len)
 		return -EINVAL;
 	}
 
-	skb = alloc_skb(NLMSG_SPACE(len), GFP_ATOMIC);
+	skb = nlmsg_new(len, GFP_ATOMIC);
 	if (!skb) {
 		pr_err("netlink_broadcast ret=%d\n", ret);
 		return -ENOMEM;
-- 
1.7.10.4
