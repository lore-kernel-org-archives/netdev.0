From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 2/2] [IPV6] RAW: Add checksum default defines for mobility header.
Date: Tue,  5 Dec 2006 19:03:27 +0900
Message-ID: <11653130071739-git-send-email-nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:55567 "EHLO
	neptune.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S967808AbWLEKD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 05:03:56 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add checksum default defines for mobility header(MH).
As the result kernel's behavior is to handle MH checksum
as default.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/ipv6/raw.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index aa1d420..389fa32 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1095,10 +1095,21 @@ static void rawv6_close(struct sock *sk,
 
 static int rawv6_init_sk(struct sock *sk)
 {
-	if (inet_sk(sk)->num == IPPROTO_ICMPV6) {
-		struct raw6_sock *rp = raw6_sk(sk);
+	struct raw6_sock *rp = raw6_sk(sk);
+
+	switch (inet_sk(sk)->num) {
+	case IPPROTO_ICMPV6:
 		rp->checksum = 1;
 		rp->offset   = 2;
+		break;
+#ifdef CONFIG_IPV6_MIP6
+	case IPPROTO_MH:
+		rp->checksum = 1;
+		rp->offset   = 4;
+		break;
+#endif
+	default:
+		break;
 	}
 	return(0);
 }
-- 
1.4.2

