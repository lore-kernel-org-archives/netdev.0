From: michele.dionisio@gmail.com
Subject: [PATCH] ipv6: make ipv6 bind honour non local bind as IPV4
Date: Thu,  9 Oct 2014 17:04:23 +0200
Message-ID: <1412867063-28433-2-git-send-email-michele.dionisio@gmail.com>
References: <1412867063-28433-1-git-send-email-michele.dionisio@gmail.com>
Cc: Michele Dionisio <michele.dionisio@gmail.com>
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:35013 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757243AbaJIPE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 11:04:56 -0400
Received: by mail-wg0-f49.google.com with SMTP id x12so1543328wgg.20
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 08:04:53 -0700 (PDT)
In-Reply-To: <1412867063-28433-1-git-send-email-michele.dionisio@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michele Dionisio <michele.dionisio@gmail.com>

---
 net/ipv6/af_inet6.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 2daa3a1..e8ca2e6 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -342,7 +342,8 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			 */
 			v4addr = LOOPBACK4_IPV6;
 			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
-				if (!(inet->freebind || inet->transparent) &&
+				if (!sysctl_ip_nonlocal_bind &&
+				    !(inet->freebind || inet->transparent) &&
 				    !ipv6_chk_addr(net, &addr->sin6_addr,
 						   dev, 0)) {
 					err = -EADDRNOTAVAIL;
-- 
2.1.1
