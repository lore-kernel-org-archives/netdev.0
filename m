From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 4/7] inet_diag: Add the SKMEMINFO extension
Date: Fri, 30 Dec 2011 14:53:32 +0400
Message-ID: <4EFD982C.8080801@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:27748 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752637Ab1L3Kxi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Dec 2011 05:53:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |    3 ++-
 net/ipv4/inet_diag.c      |    4 ++++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index afa5d5c..34e8d52 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -108,9 +108,10 @@ enum {
 	INET_DIAG_CONG,
 	INET_DIAG_TOS,
 	INET_DIAG_TCLASS,
+	INET_DIAG_SKMEMINFO,
 };
 
-#define INET_DIAG_MAX INET_DIAG_TCLASS
+#define INET_DIAG_MAX INET_DIAG_SKMEMINFO
 
 
 /* INET_DIAG_MEM */
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index fb2e47f..2240a8e 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -136,6 +136,10 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		minfo->idiag_tmem = sk_wmem_alloc_get(sk);
 	}
 
+	if (ext & (1 << (INET_DIAG_SKMEMINFO - 1)))
+		if (sock_diag_put_meminfo(sk, skb, INET_DIAG_SKMEMINFO))
+			goto rtattr_failure;
+
 	if (icsk == NULL) {
 		r->idiag_rqueue = r->idiag_wqueue = 0;
 		goto out;
-- 
1.5.5.6
