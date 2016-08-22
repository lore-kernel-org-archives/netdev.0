From: Dave Watson <davejwatson@fb.com>
Subject: [PATCH net-next] net: strparser: fix strparser sk_user_data check
Date: Mon, 22 Aug 2016 12:27:04 -0700
Message-ID: <20160822192704.GA34359@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>, Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51137 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752089AbcHVT1P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 15:27:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk_user_data mismatch between what kcm expects (psock) and what strparser expects (strparser).

Queued rx_work, for example calling strp_check_rcv after socket buffer changes, will never complete.

sk_user_data is unused in strparser, so just remove the check.

Signed-off-by: Dave Watson <davejwatson@fb.com>
---
 net/strparser/strparser.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/strparser/strparser.c b/net/strparser/strparser.c
index fd688c0..68334b5 100644
--- a/net/strparser/strparser.c
+++ b/net/strparser/strparser.c
@@ -390,9 +390,6 @@ static void do_strp_rx_work(struct strparser *strp)
 	 */
 	lock_sock(csk);
 
-	if (unlikely(csk->sk_user_data != strp))
-		goto out;
-
 	if (unlikely(strp->rx_stopped))
 		goto out;
 
-- 
2.8.0.rc2
