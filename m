From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH] net: inet_diag: export IPV6_V6ONLY sockopt
Date: Fri, 19 Jun 2015 14:15:32 +0200
Message-ID: <1434716132-25103-1-git-send-email-phil@nwl.cc>
References: <20150615205421.GA22616@orbit.nwl.cc>
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:52290 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193AbbFSMPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2015 08:15:34 -0400
In-Reply-To: <20150615205421.GA22616@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For AF_INET6 sockets, the value of struct ipv6_pinfo.ipv6only is
exported to userspace. It indicates whether an unbound socket listens on
IPv4 as well as IPv6. Since the socket is natively IPv6, it is not
listed by e.g. 'netstat -l -4'.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
This patch is accompanied by an appropriate one for iproute2 to enable
the additional information in 'ss -e'.
---
 include/uapi/linux/inet_diag.h | 3 ++-
 net/ipv4/inet_diag.c           | 4 ++++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index c7093c7..9ca4834 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -111,9 +111,10 @@ enum {
 	INET_DIAG_SKMEMINFO,
 	INET_DIAG_SHUTDOWN,
 	INET_DIAG_DCTCPINFO,
+	INET_DIAG_SKV6ONLY,
 };
 
-#define INET_DIAG_MAX INET_DIAG_DCTCPINFO
+#define INET_DIAG_MAX INET_DIAG_SKV6ONLY
 
 /* INET_DIAG_MEM */
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 4d32262..4bf6d03 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -151,6 +151,10 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 			if (nla_put_u8(skb, INET_DIAG_TCLASS,
 				       inet6_sk(sk)->tclass) < 0)
 				goto errout;
+
+		if (nla_put_u8(skb, INET_DIAG_SKV6ONLY,
+				inet6_sk(sk)->ipv6only) < 0)
+			goto errout;
 	}
 #endif
 
-- 
2.1.2
