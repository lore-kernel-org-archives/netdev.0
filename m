From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 1/5] [PATCH] af_iucv: consider state IUCV_CLOSING when closing a socket
Date: Tue, 21 Apr 2009 18:04:20 +0200
Message-ID: <20090421161444.298976000@linux.vnet.ibm.com>
References: <20090421160419.971500000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:52476 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516AbZDUQPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 12:15:35 -0400
Content-Disposition: inline; filename=602-af_iucv-closing.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Make sure a second invocation of iucv_sock_close() guarantees proper
freeing of an iucv path.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/af_iucv.c |    3 +++
 1 file changed, 3 insertions(+)

Index: net-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6-uschi/net/iucv/af_iucv.c
@@ -172,6 +172,7 @@ static void iucv_sock_close(struct sock 
 			err = iucv_sock_wait_state(sk, IUCV_CLOSED, 0, timeo);
 		}
 
+	case IUCV_CLOSING:   /* fall through */
 		sk->sk_state = IUCV_CLOSED;
 		sk->sk_state_change(sk);
 
@@ -224,6 +225,8 @@ static struct sock *iucv_sock_alloc(stru
 	spin_lock_init(&iucv_sk(sk)->message_q.lock);
 	skb_queue_head_init(&iucv_sk(sk)->backlog_skb_q);
 	iucv_sk(sk)->send_tag = 0;
+	iucv_sk(sk)->path = NULL;
+	memset(&iucv_sk(sk)->src_user_id , 0, 32);
 
 	sk->sk_destruct = iucv_sock_destruct;
 	sk->sk_sndtimeo = IUCV_CONN_TIMEOUT;

