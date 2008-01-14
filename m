From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 3/4][NETNS][RAW]: Eliminate explicit init_net references.
Date: Mon, 14 Jan 2008 16:11:17 +0300
Message-ID: <478B5F75.70608@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58297 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753304AbYANNLR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 08:11:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Happily, in all the rest places (->bind callbacks only), that require the 
struct net, we have a socket, so get the net from it.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/raw.c |    2 +-
 net/ipv6/raw.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 4e95372..206c869 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -625,7 +625,7 @@ static int raw_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	if (sk->sk_state != TCP_CLOSE || addr_len < sizeof(struct sockaddr_in))
 		goto out;
-	chk_addr_ret = inet_addr_type(&init_net, addr->sin_addr.s_addr);
+	chk_addr_ret = inet_addr_type(sk->sk_net, addr->sin_addr.s_addr);
 	ret = -EADDRNOTAVAIL;
 	if (addr->sin_addr.s_addr && chk_addr_ret != RTN_LOCAL &&
 	    chk_addr_ret != RTN_MULTICAST && chk_addr_ret != RTN_BROADCAST)
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 026fa91..970529e 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -291,7 +291,7 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 			if (!sk->sk_bound_dev_if)
 				goto out;
 
-			dev = dev_get_by_index(&init_net, sk->sk_bound_dev_if);
+			dev = dev_get_by_index(sk->sk_net, sk->sk_bound_dev_if);
 			if (!dev) {
 				err = -ENODEV;
 				goto out;
@@ -304,7 +304,7 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		v4addr = LOOPBACK4_IPV6;
 		if (!(addr_type & IPV6_ADDR_MULTICAST))	{
 			err = -EADDRNOTAVAIL;
-			if (!ipv6_chk_addr(&init_net, &addr->sin6_addr,
+			if (!ipv6_chk_addr(sk->sk_net, &addr->sin6_addr,
 					   dev, 0)) {
 				if (dev)
 					dev_put(dev);
-- 
1.5.3.4

