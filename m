From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [IPV6] fix inet6_sk for non IPV6 builds
Date: Wed, 29 Dec 2004 20:32:15 -0200
Message-ID: <41D3306F.7080605@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090801080902000902020809"
Cc: Networking Team <netdev@oss.sgi.com>,
        James.Bottomley@HansenPartnership.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090801080902000902020809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please apply this patch, the problem was noted by James Bottomley, that
doesn't enables CONFIG_IPV6.

Signed-off-by: Arnaldo Carvalho de Melo

- Arnaldo

--------------090801080902000902020809
Content-Type: text/plain;
 name="inet6_sk.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="inet6_sk.patch"

===== include/linux/ipv6.h 1.23 vs edited =====
--- 1.23/include/linux/ipv6.h	2004-12-27 23:56:33 -02:00
+++ edited/include/linux/ipv6.h	2004-12-29 20:22:45 -02:00
@@ -273,6 +273,7 @@
 	struct ipv6_pinfo inet6;
 };
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
 {
 	return inet_sk(__sk)->pinet6;
@@ -283,7 +284,6 @@
 	return &((struct raw6_sock *)__sk)->raw6;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #define __ipv6_only_sock(sk)	(inet6_sk(sk)->ipv6only)
 #define ipv6_only_sock(sk)	((sk)->sk_family == PF_INET6 && __ipv6_only_sock(sk))
 #else

--------------090801080902000902020809--
