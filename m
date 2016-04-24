From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next] sctp: sctp_diag should fill RMEM_ALLOC with asoc->rmem_alloc when rcvbuf_policy is set
Date: Sun, 24 Apr 2016 23:21:22 +0800
Message-ID: <f21861d502b04cf3752dce4cde8cd3f5f1806571.1461511282.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net, eric.dumazet@gmail.com
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36068 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752888AbcDXPV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 11:21:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For sctp assoc, when rcvbuf_policy is set, it will has it's own
rmem_alloc, when we dump asoc info in sctp_diag, we should use that
value on RMEM_ALLOC as well, just like WMEM_ALLOC.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sctp_diag.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
index bb2d8d9..b5269df 100644
--- a/net/sctp/sctp_diag.c
+++ b/net/sctp/sctp_diag.c
@@ -145,7 +145,11 @@ static int inet_sctp_diag_fill(struct sock *sk, struct sctp_association *asoc,
 		else
 			amt = sk_wmem_alloc_get(sk);
 		mem[SK_MEMINFO_WMEM_ALLOC] = amt;
-		mem[SK_MEMINFO_RMEM_ALLOC] = sk_rmem_alloc_get(sk);
+		if (asoc && asoc->ep->rcvbuf_policy)
+			amt = atomic_read(&asoc->rmem_alloc);
+		else
+			amt = sk_rmem_alloc_get(sk);
+		mem[SK_MEMINFO_RMEM_ALLOC] = amt;
 		mem[SK_MEMINFO_RCVBUF] = sk->sk_rcvbuf;
 		mem[SK_MEMINFO_SNDBUF] = sk->sk_sndbuf;
 		mem[SK_MEMINFO_FWD_ALLOC] = sk->sk_forward_alloc;
-- 
2.1.0
