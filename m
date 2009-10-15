From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 1/5] [PATCH] af_iucv: use sk functions to modify sk->sk_ack_backlog
Date: Thu, 15 Oct 2009 10:54:55 +0200
Message-ID: <20091015090749.502120000@linux.vnet.ibm.com>
References: <20091015085454.124154000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:60679 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756270AbZJOJI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 05:08:27 -0400
Content-Disposition: inline; filename=601-af_iucv-use-sk-fns.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

Instead of modifying sk->sk_ack_backlog directly, use respective
socket functions.

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/af_iucv.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-next-uschi/net/iucv/af_iucv.c
===================================================================
--- linux-next-uschi.orig/net/iucv/af_iucv.c
+++ linux-next-uschi/net/iucv/af_iucv.c
@@ -536,7 +536,7 @@ void iucv_accept_enqueue(struct sock *pa
 	list_add_tail(&iucv_sk(sk)->accept_q, &par->accept_q);
 	spin_unlock_irqrestore(&par->accept_q_lock, flags);
 	iucv_sk(sk)->parent = parent;
-	parent->sk_ack_backlog++;
+	sk_acceptq_added(parent);
 }
 
 void iucv_accept_unlink(struct sock *sk)
@@ -547,7 +547,7 @@ void iucv_accept_unlink(struct sock *sk)
 	spin_lock_irqsave(&par->accept_q_lock, flags);
 	list_del_init(&iucv_sk(sk)->accept_q);
 	spin_unlock_irqrestore(&par->accept_q_lock, flags);
-	iucv_sk(sk)->parent->sk_ack_backlog--;
+	sk_acceptq_removed(iucv_sk(sk)->parent);
 	iucv_sk(sk)->parent = NULL;
 	sock_put(sk);
 }

