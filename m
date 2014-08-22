From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 1/2] net: sctp: spare unnecessary comparison in sctp_trans_elect_best
Date: Fri, 22 Aug 2014 13:03:29 +0200
Message-ID: <1408705410-28558-2-git-send-email-dborkman@redhat.com>
References: <1408705410-28558-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56724 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755300AbaHVLDf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Aug 2014 07:03:35 -0400
In-Reply-To: <1408705410-28558-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When both transports are the same, we don't have to go down that
road only to realize that we will return the very same transport.
We are guaranteed that curr is always non-NULL. Therefore, just
short-circuit this special case.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/associola.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index aaafb32..104fae4 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1245,7 +1245,7 @@ static struct sctp_transport *sctp_trans_elect_best(struct sctp_transport *curr,
 {
 	u8 score_curr, score_best;
 
-	if (best == NULL)
+	if (best == NULL || curr == best)
 		return curr;
 
 	score_curr = sctp_trans_score(curr);
-- 
1.7.11.7
