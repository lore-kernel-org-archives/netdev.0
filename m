From: Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Subject: [PATCH] Phonet: Correct header retrieval after pskb_may_pull
Date: Tue, 28 Sep 2010 14:40:42 +0530
Message-ID: <1285665042-20548-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <gulshan.karmani@stericsson.com>,
	Kumar Sanghvi <kumar.sanghvi@stericsson.com>,
	Linus Walleij <linus.walleij@stericsson.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<remi.denis-courmont@nokia.com>, <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:37093 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753214Ab0I1JLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 05:11:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumar.sanghvi@stericsson.com>

Retrieve the header after doing pskb_may_pull since, pskb_may_pull
could change the buffer structure.

This is based on the comment given by Eric Dumazet on Phonet
Pipe controller patch for a similar problem.

Signed-off-by: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
Acked-by: Linus Walleij <linus.walleij@stericsson.com>
---
 net/phonet/pep.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 7bf23cf..9746c6d 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -507,12 +507,13 @@ static void pipe_grant_credits(struct sock *sk)
 static int pipe_rcv_status(struct sock *sk, struct sk_buff *skb)
 {
 	struct pep_sock *pn = pep_sk(sk);
-	struct pnpipehdr *hdr = pnp_hdr(skb);
+	struct pnpipehdr *hdr;
 	int wake = 0;
 
 	if (!pskb_may_pull(skb, sizeof(*hdr) + 4))
 		return -EINVAL;
 
+	hdr = pnp_hdr(skb);
 	if (hdr->data[0] != PN_PEP_TYPE_COMMON) {
 		LIMIT_NETDEBUG(KERN_DEBUG"Phonet unknown PEP type: %u\n",
 				(unsigned)hdr->data[0]);
-- 
1.7.2.dirty

