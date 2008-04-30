From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][IPV6]: Compilation fix for compat MCAST_MSFILTER sockopts.
Date: Wed, 30 Apr 2008 17:36:31 +0400
Message-ID: <481875DF.2020401@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55874 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754486AbYD3N7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2008 09:59:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The last hunk from the commit dae50295 (ipv4/ipv6 compat: Fix SSM
applications on 64bit kernels.) escaped from the compat_ipv6_setsockopt
to the ipv6_getsockopt (I guess due to patch smartness wrt searching
for context) thus breaking 32-bit and 64-bit-without-compat compilation.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index b4a26f2..56d55fe 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1089,10 +1089,6 @@ int ipv6_getsockopt(struct sock *sk, int level, int optname,
 	if(level != SOL_IPV6)
 		return -ENOPROTOOPT;
 
-	if (optname == MCAST_MSFILTER)
-		return compat_mc_getsockopt(sk, level, optname, optval, optlen,
-			ipv6_getsockopt);
-
 	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
@@ -1131,6 +1127,10 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
 	if (level != SOL_IPV6)
 		return -ENOPROTOOPT;
 
+	if (optname == MCAST_MSFILTER)
+		return compat_mc_getsockopt(sk, level, optname, optval, optlen,
+			ipv6_getsockopt);
+
 	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
