From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 3/5] inet_diag: Extend the meminfo report
Date: Wed, 28 Dec 2011 17:38:40 +0400
Message-ID: <4EFB1BE0.1020305@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:36027 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753770Ab1L1Niq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 08:38:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the backlog length and wmem and rmem buffers limits.
With this the TCP memory info is full and can be analyzed.

Few words about extending the existing structure. The nla engine stores lengths of
fields and the nla parser will parse the new format successfully (checked on the ss
tool). But new apps will have to take this field's length into account. Hopefully
this is acceptable price for not introducing another ext bit and structure.

Singed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |    3 +++
 net/ipv4/inet_diag.c      |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index afa5d5c..d274712 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -120,6 +120,9 @@ struct inet_diag_meminfo {
 	__u32	idiag_wmem;
 	__u32	idiag_fmem;
 	__u32	idiag_tmem;
+	__u32	idiag_backlog;
+	__u32	idiag_rcvbuf;
+	__u32	idiag_sndbuf;
 };
 
 /* INET_DIAG_VEGASINFO */
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index fb2e47f..91f9092 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -134,6 +134,9 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		minfo->idiag_wmem = sk->sk_wmem_queued;
 		minfo->idiag_fmem = sk->sk_forward_alloc;
 		minfo->idiag_tmem = sk_wmem_alloc_get(sk);
+		minfo->idiag_backlog = sk->sk_backlog.len;
+		minfo->idiag_rcvbuf = sk->sk_rcvbuf;
+		minfo->idiag_sndbuf = sk->sk_sndbuf;
 	}
 
 	if (icsk == NULL) {
-- 
1.5.5.6
