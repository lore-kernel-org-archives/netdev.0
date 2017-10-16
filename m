From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next v2 1/2] net: move memcpy_to[from]_msg() from skbuff.h to socket.h
Date: Mon, 16 Oct 2017 20:10:42 +0800
Message-ID: <1508155842-23696-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:43930 "EHLO m12-15.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751637AbdJPMLM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 08:11:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

these two functions used by skb and other places,
move to socket.h where struct msghdr defined.

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 include/linux/skbuff.h | 10 ----------
 include/linux/socket.h | 13 ++++++++++++-
 2 files changed, 12 insertions(+), 11 deletions(-)

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
index 8ad963c..0a2048e 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -2,6 +2,7 @@
 #define _LINUX_SOCKET_H
 
 
+#include <linux/errno.h>
 #include <asm/socket.h>			/* arch-dependent defines	*/
 #include <linux/sockios.h>		/* the SIOCxxx I/O controls	*/
 #include <linux/uio.h>			/* iovec support		*/
@@ -53,7 +54,17 @@ struct msghdr {
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
