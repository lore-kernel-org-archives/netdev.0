From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH net-next v2] IPv6: enable bind() to assign an anycast address
Date: Wed, 12 Feb 2014 14:38:51 +0100
Message-ID: <1392212332-10463-1-git-send-email-fx.lebail@yahoo.com>
To: NETDEV <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp01.smtpout.orange.fr ([80.12.242.123]:21722 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbaBLNkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 08:40:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Use ipv6_chk_acast_addr_src() in inet6_bind().

Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
v2: ipv6_chk_acast_addr_src() was previously added.

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
