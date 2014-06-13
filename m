From: Xiangyu Lu <luxiangyu@huawei.com>
Subject: [PATCH 1/5] netlink: Rename netlink_capable netlink_allowed
Date: Fri, 13 Jun 2014 01:31:06 +0000
Message-ID: <1402623070-26549-2-git-send-email-luxiangyu@huawei.com>
References: <1402623070-26549-1-git-send-email-luxiangyu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stable@vger.kernel.org>, <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Xiangyu Lu <luxiangyu@huawei.com>
To: <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1402623070-26549-1-git-send-email-luxiangyu@huawei.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm@xmission.com>

commit 5187cd055b6e81fc6526109456f8b20623148d5f upstream.

netlink_capable is a static internal function in af_netlink.c and we
have better uses for the name netlink_capable.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
[xl: Backported to 3.10: adjust context]
Signed-off-by: Xiangyu Lu <luxiangyu@huawei.com>
---
 net/netlink/af_netlink.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c9c2a84..3f1d67e 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1219,7 +1219,7 @@ retry:
 	return err;
 }
 
-static inline int netlink_capable(const struct socket *sock, unsigned int flag)
+static inline int netlink_allowed(const struct socket *sock, unsigned int flag)
 {
 	return (nl_table[sock->sk->sk_protocol].flags & flag) ||
 		ns_capable(sock_net(sock->sk)->user_ns, CAP_NET_ADMIN);
@@ -1287,7 +1287,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 
 	/* Only superuser is allowed to listen multicasts */
 	if (nladdr->nl_groups) {
-		if (!netlink_capable(sock, NL_CFG_F_NONROOT_RECV))
+		if (!netlink_allowed(sock, NL_CFG_F_NONROOT_RECV))
 			return -EPERM;
 		err = netlink_realloc_groups(sk);
 		if (err)
@@ -1349,7 +1349,7 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 		return -EINVAL;
 
 	/* Only superuser is allowed to send multicasts */
-	if (nladdr->nl_groups && !netlink_capable(sock, NL_CFG_F_NONROOT_SEND))
+	if (nladdr->nl_groups && !netlink_allowed(sock, NL_CFG_F_NONROOT_SEND))
 		return -EPERM;
 
 	if (!nlk->portid)
@@ -1921,7 +1921,7 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 		break;
 	case NETLINK_ADD_MEMBERSHIP:
 	case NETLINK_DROP_MEMBERSHIP: {
-		if (!netlink_capable(sock, NL_CFG_F_NONROOT_RECV))
+		if (!netlink_allowed(sock, NL_CFG_F_NONROOT_RECV))
 			return -EPERM;
 		err = netlink_realloc_groups(sk);
 		if (err)
@@ -2072,7 +2072,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		dst_group = ffs(addr->nl_groups);
 		err =  -EPERM;
 		if ((dst_group || dst_portid) &&
-		    !netlink_capable(sock, NL_CFG_F_NONROOT_SEND))
+		    !netlink_allowed(sock, NL_CFG_F_NONROOT_SEND))
 			goto out;
 	} else {
 		dst_portid = nlk->dst_portid;
-- 
1.8.3.4
