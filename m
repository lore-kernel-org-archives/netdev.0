From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 04/13] [PATCH] af_iucv: Reject incoming msgs if RECV_SHUTDOWN is set
Date: Tue, 21 Apr 2009 12:35:01 +0200
Message-ID: <20090421103705.603001000@linux.vnet.ibm.com>
References: <20090421103457.965299000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:45212 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193AbZDUKhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 06:37:07 -0400
Content-Disposition: inline; filename=604-af_iucv-rej-msgs.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

Reject incoming iucv messages if the receive direction has been shut down.
It avoids that the queue of outstanding messages increases and exceeds the
message limit of the iucv communication path.

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/af_iucv.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: net-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6-uschi/net/iucv/af_iucv.c
@@ -1116,8 +1116,10 @@ static void iucv_callback_rx(struct iucv
 	struct sock_msg_q *save_msg;
 	int len;
 
-	if (sk->sk_shutdown & RCV_SHUTDOWN)
+	if (sk->sk_shutdown & RCV_SHUTDOWN) {
+		iucv_message_reject(path, msg);
 		return;
+	}
 
 	if (!list_empty(&iucv->message_q.list) ||
 	    !skb_queue_empty(&iucv->backlog_skb_q))

