From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 1/2] net: move memcpy_to[from]_msg() from skbuff.h to socket.h
Date: Sat, 14 Oct 2017 10:26:33 +0800
Message-ID: <1507947993-4728-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:44177 "EHLO m12-12.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751572AbdJNCmI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 22:42:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

these two functions used by skb and other places,
move to socket.h where struct msghdr defined.

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 include/linux/skbuff.h | 10 ----------
 include/linux/socket.h | 12 +++++++++++-
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 03634ec2..90868d1 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3294,16 +3294,6 @@ int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
 struct sk_buff *pskb_extract(struct sk_buff *skb, int off, int to_copy,
 			     gfp_t gfp);
 
-static inline int memcpy_from_msg(void *data, struct msghdr *msg, int len)
-{
-	return copy_from_iter_full(data, len, &msg->msg_iter) ? 0 : -EFAULT;
-}
-
-static inline int memcpy_to_msg(struct msghdr *msg, void *data, int len)
-{
-	return copy_to_iter(data, len, &msg->msg_iter) == len ? 0 : -EFAULT;
-}
-
 struct skb_checksum_ops {
 	__wsum (*update)(const void *mem, int len, __wsum wsum);
 	__wsum (*combine)(__wsum csum, __wsum csum2, int offset, int len);
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 8ad963c..c414f1f 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -53,7 +53,17 @@ struct msghdr {
 	unsigned int	msg_flags;	/* flags on received message */
 	struct kiocb	*msg_iocb;	/* ptr to iocb for async requests */
 };
- 
+
+static inline int memcpy_from_msg(void *data, struct msghdr *msg, int len)
+{
+	return copy_from_iter_full(data, len, &msg->msg_iter) ? 0 : -EFAULT;
+}
+
+static inline int memcpy_to_msg(struct msghdr *msg, void *data, int len)
+{
+	return copy_to_iter(data, len, &msg->msg_iter) == len ? 0 : -EFAULT;
+}
+
 struct user_msghdr {
 	void		__user *msg_name;	/* ptr to socket address structure */
 	int		msg_namelen;		/* size of socket address structure */
-- 
2.7.4
