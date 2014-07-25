From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH v2 4/8] netlink: Rename netlink_capable netlink_allowed
Date: Fri, 25 Jul 2014 16:22:25 +0800
Message-ID: <1406276549-6616-5-git-send-email-wangyufen@huawei.com>
References: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:34868 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759918AbaGYIYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 04:24:40 -0400
In-Reply-To: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

netlink_capable is a static internal function in af_netlink.c and we
have better uses for the name netlink_capable.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 net/netlink/af_netlink.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 571fc2c..18b4cc6 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -590,7 +590,7 @@ retry:
 	return err;
 }
 
-static inline int netlink_capable(const struct socket *sock, unsigned int flag)
+static inline int netlink_allowed(const struct socket *sock, unsigned int flag)
 {
 	return (nl_table[sock->sk->sk_protocol].nl_nonroot & flag) ||
 	       capable(CAP_NET_ADMIN);
@@ -655,7 +655,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 
 	/* Only superuser is allowed to listen multicasts */
 	if (nladdr->nl_groups) {
-		if (!netlink_capable(sock, NL_NONROOT_RECV))
+		if (!netlink_allowed(sock, NL_NONROOT_RECV))
 			return -EPERM;
 		err = netlink_realloc_groups(sk);
 		if (err)
@@ -708,7 +708,7 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 		return -EINVAL;
 
 	/* Only superuser is allowed to send multicasts */
-	if (nladdr->nl_groups && !netlink_capable(sock, NL_NONROOT_SEND))
+	if (nladdr->nl_groups && !netlink_allowed(sock, NL_NONROOT_SEND))
 		return -EPERM;
 
 	if (!nlk->pid)
@@ -1229,7 +1229,7 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 		break;
 	case NETLINK_ADD_MEMBERSHIP:
 	case NETLINK_DROP_MEMBERSHIP: {
-		if (!netlink_capable(sock, NL_NONROOT_RECV))
+		if (!netlink_allowed(sock, NL_NONROOT_RECV))
 			return -EPERM;
 		err = netlink_realloc_groups(sk);
 		if (err)
@@ -1356,7 +1356,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		dst_group = ffs(addr->nl_groups);
 		err =  -EPERM;
 		if ((dst_group || dst_pid) &&
-		    !netlink_capable(sock, NL_NONROOT_SEND))
+		    !netlink_allowed(sock, NL_NONROOT_SEND))
 			goto out;
 	} else {
 		dst_pid = nlk->dst_pid;
-- 
1.8.0
