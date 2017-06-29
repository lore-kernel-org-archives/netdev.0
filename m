From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next] sctp: remove an unnecessary check from sctp_endpoint_destroy
Date: Thu, 29 Jun 2017 17:28:06 +0800
Message-ID: <9a583ea8d84ee913f4c7ba1571e6cfeb24c9ef8b.1498728486.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36471 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751565AbdF2J2Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 05:28:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ep->base.sk gets it's value since sctp_endpoint_new, nowhere
will change it. So there's no need to check if it's null, as
it can never be null.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/endpointola.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 3dcd0ec..7772ca4 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -268,16 +268,14 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
 
 	memset(ep->secret_key, 0, sizeof(ep->secret_key));
 
-	/* Give up our hold on the sock. */
 	sk = ep->base.sk;
-	if (sk != NULL) {
-		/* Remove and free the port */
-		if (sctp_sk(sk)->bind_hash)
-			sctp_put_port(sk);
+	/* Remove and free the port */
+	if (sctp_sk(sk)->bind_hash)
+		sctp_put_port(sk);
 
-		sctp_sk(sk)->ep = NULL;
-		sock_put(sk);
-	}
+	sctp_sk(sk)->ep = NULL;
+	/* Give up our hold on the sock */
+	sock_put(sk);
 
 	kfree(ep);
 	SCTP_DBG_OBJCNT_DEC(ep);
-- 
2.1.0
