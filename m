From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next] sctp: change sk state to CLOSED instead of CLOSING in sctp_sock_migrate
Date: Thu, 16 Jun 2016 01:15:06 +0800
Message-ID: <9229f8aa0f4324831fc31b5334cde9a258404b62.1466010906.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	xiaolong.ye@intel.com, davem@davemloft.net, eric.dumazet@gmail.com
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34556 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765AbcFORPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 13:15:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d46e416c11c8 ("sctp: sctp should change socket state when
shutdown is received") may set sk_state CLOSING in sctp_sock_migrate,
but inet_accept doesn't allow the sk_state other than ESTABLISHED/
CLOSED for sctp. So we will change sk_state to CLOSED, instead of
CLOSING, as actually sk is closed already there.

Fixes: commit d46e416c11c8 ("sctp: sctp should change socket state when shutdown is received")
Reported-by: Ye Xiaolong <xiaolong.ye@intel.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 6cae4c6..cdabbd8 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -7568,7 +7568,7 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	 * is called, set RCV_SHUTDOWN flag.
 	 */
 	if (sctp_state(assoc, CLOSED) && sctp_style(newsk, TCP)) {
-		newsk->sk_state = SCTP_SS_CLOSING;
+		newsk->sk_state = SCTP_SS_CLOSED;
 		newsk->sk_shutdown |= RCV_SHUTDOWN;
 	} else {
 		newsk->sk_state = SCTP_SS_ESTABLISHED;
-- 
2.1.0
