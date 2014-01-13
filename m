From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH net-next v2] IPv6: enable bind() to assign an anycast address
Date: Mon, 13 Jan 2014 17:59:37 +0100
Message-ID: <1389632378-4996-1-git-send-email-fx.lebail@yahoo.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp06.smtpout.orange.fr ([80.12.242.128]:35280 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753024AbaAMRSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 12:18:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Use ipv6_chk_acast_addr_src() in inet6_bind().

Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
Tested with SOCK_DGRAM and SOCK_STREAM sockets.
Tested with link-local and global anycast addresses.

 net/ipv6/af_inet6.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index c921d5d..68b81e9 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -347,7 +347,9 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
 				if (!(inet->freebind || inet->transparent) &&
 				    !ipv6_chk_addr(net, &addr->sin6_addr,
-						   dev, 0)) {
+						   dev, 0) &&
+				    !ipv6_chk_acast_addr_src(net, dev,
+							     &addr->sin6_addr)) {
 					err = -EADDRNOTAVAIL;
 					goto out_unlock;
 				}
