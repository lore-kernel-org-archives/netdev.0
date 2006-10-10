From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 2/2][SCTP]: Fix the RX queue size shown in
	/proc/net/sctp/assocs output.
Date: Mon, 09 Oct 2006 17:43:12 -0700
Message-ID: <1160440992.27455.6.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:55000 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S964881AbWJJAnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 20:43:14 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9A0hDNM025369
	for <netdev@vger.kernel.org>; Mon, 9 Oct 2006 20:43:14 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9A0hE7n095666
	for <netdev@vger.kernel.org>; Mon, 9 Oct 2006 20:43:14 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9A0hDFf031248
	for <netdev@vger.kernel.org>; Mon, 9 Oct 2006 20:43:13 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Fix the RX queue size shown in /proc/net/sctp/assocs output.

Show the true receive buffer usage.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index a356d8d..7f49e76 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -344,7 +344,7 @@ static int sctp_assocs_seq_show(struct s
 			   assoc, sk, sctp_sk(sk)->type, sk->sk_state,
 			   assoc->state, hash, assoc->assoc_id,
 			   assoc->sndbuf_used,
-			   (sk->sk_rcvbuf - assoc->rwnd),
+			   atomic_read(&assoc->rmem_alloc),
 			   sock_i_uid(sk), sock_i_ino(sk),
 			   epb->bind_addr.port,
 			   assoc->peer.port);


