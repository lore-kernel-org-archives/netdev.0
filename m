From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [PATCH] net: netlink_getname, packet_getname -- use
	DECLARE_SOCKADDR guard
Date: Sun, 8 Nov 2009 18:51:19 +0300
Message-ID: <20091108155119.GA25940@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: LNML <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:62108 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515AbZKHPvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 10:51:16 -0500
Received: by ewy3 with SMTP id 3so2432149ewy.37
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2009 07:51:20 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use guard DECLARE_SOCKADDR in a few more places which allow
us to catch if the structure copied back is too big.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---

Please review, comments are welcome!

 net/netlink/af_netlink.c |    2 +-
 net/packet/af_packet.c   |    2 +-
 net/unix/af_unix.c       |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6.git/net/netlink/af_netlink.c
=====================================================================
--- linux-2.6.git.orig/net/netlink/af_netlink.c
+++ linux-2.6.git/net/netlink/af_netlink.c
@@ -707,7 +707,7 @@ static int netlink_getname(struct socket
 {
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
-	struct sockaddr_nl *nladdr = (struct sockaddr_nl *)addr;
+	DECLARE_SOCKADDR(struct sockaddr_nl *, nladdr, addr);
 
 	nladdr->nl_family = AF_NETLINK;
 	nladdr->nl_pad = 0;
Index: linux-2.6.git/net/packet/af_packet.c
=====================================================================
--- linux-2.6.git.orig/net/packet/af_packet.c
+++ linux-2.6.git/net/packet/af_packet.c
@@ -1532,7 +1532,7 @@ static int packet_getname(struct socket 
 	struct net_device *dev;
 	struct sock *sk = sock->sk;
 	struct packet_sock *po = pkt_sk(sk);
-	struct sockaddr_ll *sll = (struct sockaddr_ll *)uaddr;
+	DECLARE_SOCKADDR(struct sockaddr_ll *, sll, uaddr);
 
 	if (peer)
 		return -EOPNOTSUPP;
Index: linux-2.6.git/net/unix/af_unix.c
=====================================================================
--- linux-2.6.git.orig/net/unix/af_unix.c
+++ linux-2.6.git/net/unix/af_unix.c
@@ -1258,7 +1258,7 @@ static int unix_getname(struct socket *s
 {
 	struct sock *sk = sock->sk;
 	struct unix_sock *u;
-	struct sockaddr_un *sunaddr = (struct sockaddr_un *)uaddr;
+	DECLARE_SOCKADDR(struct sockaddr_un *, sunaddr, uaddr);
 	int err = 0;
 
 	if (peer) {
