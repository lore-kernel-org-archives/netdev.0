From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/6] netlink:  Rename netlink_capable netlink_allowed
Date: Tue, 22 Apr 2014 14:14:51 -0700
Message-ID: <87lhuxnk1g.fsf_-_@x220.int.ebiederm.org>
References: <CALCETrUaYhh6Dkzn0TMEUz-GEO9-6ObByk5d_xRViSMBbp5Pkg@mail.gmail.com>
	<cover.1397840611.git.luto@amacapital.net>
	<6daf425e2023266d52d181e4d2ee18747d4f1fa8.1397840611.git.luto@amacapital.net>
	<87tx9nuxf6.fsf@x220.int.ebiederm.org>
	<CALCETrUqNVRBse4rUeUKfgYt0d+9x1JrEHGcZ_DnWyq7W6Yyzw@mail.gmail.com>
	<87r44qtabz.fsf@x220.int.ebiederm.org>
	<CALCETrWzUQ7QjykT85ExDfX-+9eDD-D-dcxofUMPvLK=ia9arg@mail.gmail.com>
	<87r44qrt8v.fsf_-_@x220.int.ebiederm.org>
	<87r44pnk3c.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vivek Goyal <vgoyal@redhat.com>, Simo Sorce <ssorce@redhat.com>,
	"security\@kernel.org" <security@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	<netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49011 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491AbaDVVPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 17:15:22 -0400
In-Reply-To: <87r44pnk3c.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Tue, 22 Apr 2014 14:13:43 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


netlink_capable is a static internal function in af_netlink.c and we
have better uses for the name netlink_capable.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netlink/af_netlink.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 894cda0206bb..7f931fe4d187 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1360,7 +1360,7 @@ retry:
 	return err;
 }
 
-static inline int netlink_capable(const struct socket *sock, unsigned int flag)
+static inline int netlink_allowed(const struct socket *sock, unsigned int flag)
 {
 	return (nl_table[sock->sk->sk_protocol].flags & flag) ||
 		ns_capable(sock_net(sock->sk)->user_ns, CAP_NET_ADMIN);
@@ -1428,7 +1428,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 
 	/* Only superuser is allowed to listen multicasts */
 	if (nladdr->nl_groups) {
-		if (!netlink_capable(sock, NL_CFG_F_NONROOT_RECV))
+		if (!netlink_allowed(sock, NL_CFG_F_NONROOT_RECV))
 			return -EPERM;
 		err = netlink_realloc_groups(sk);
 		if (err)
@@ -1490,7 +1490,7 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 		return -EINVAL;
 
 	if ((nladdr->nl_groups || nladdr->nl_pid) &&
-	    !netlink_capable(sock, NL_CFG_F_NONROOT_SEND))
+	    !netlink_allowed(sock, NL_CFG_F_NONROOT_SEND))
 		return -EPERM;
 
 	if (!nlk->portid)
@@ -2096,7 +2096,7 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 		break;
 	case NETLINK_ADD_MEMBERSHIP:
 	case NETLINK_DROP_MEMBERSHIP: {
-		if (!netlink_capable(sock, NL_CFG_F_NONROOT_RECV))
+		if (!netlink_allowed(sock, NL_CFG_F_NONROOT_RECV))
 			return -EPERM;
 		err = netlink_realloc_groups(sk);
 		if (err)
@@ -2247,7 +2247,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		dst_group = ffs(addr->nl_groups);
 		err =  -EPERM;
 		if ((dst_group || dst_portid) &&
-		    !netlink_capable(sock, NL_CFG_F_NONROOT_SEND))
+		    !netlink_allowed(sock, NL_CFG_F_NONROOT_SEND))
 			goto out;
 	} else {
 		dst_portid = nlk->dst_portid;
-- 
1.9.1
