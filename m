From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: do not mark sk dumped when inet_sctp_diag_fill returns err
Date: Fri, 15 Sep 2017 11:02:48 +0800
Message-ID: <c5398945d4e80ed8b8497675dd0449763fec4eec.1505444568.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37253 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751876AbdIODC4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 23:02:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_diag would not actually dump out sk/asoc if inet_sctp_diag_fill
returns err, in which case it shouldn't mark sk dumped by setting
cb->args[3] as 1 in sctp_sock_dump().

Otherwise, it could cause some asocs to have no parent's sk dumped
in 'ss --sctp'.

So this patch is to not set cb->args[3] when inet_sctp_diag_fill()
returns err in sctp_sock_dump().

Fixes: 8f840e47f190 ("sctp: add the sctp_diag.c file")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sctp_diag.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
index 7008a99..22ed01a 100644
--- a/net/sctp/sctp_diag.c
+++ b/net/sctp/sctp_diag.c
@@ -309,7 +309,6 @@ static int sctp_sock_dump(struct sctp_transport *tsp, void *p)
 					cb->nlh->nlmsg_seq,
 					NLM_F_MULTI, cb->nlh,
 					commp->net_admin) < 0) {
-			cb->args[3] = 1;
 			err = 1;
 			goto release;
 		}
-- 
2.1.0
