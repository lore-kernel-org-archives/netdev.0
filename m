From: frank.blaschka@de.ibm.com
Subject: [patch 8/9] [PATCH] af_iucv: get rid of compile warning
Date: Fri, 13 May 2011 06:45:08 +0200
Message-ID: <20110513044548.183833947@de.ibm.com>
References: <20110513044500.190198403@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:55111 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915Ab1EMEpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 00:45:50 -0400
Content-Disposition: inline; filename=607-af_iucv-compile-warning.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

-Wunused-but-set-variable generates compile warnings. The affected
variables are removed.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 net/iucv/af_iucv.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -190,7 +190,6 @@ static int afiucv_pm_freeze(struct devic
  */
 static int afiucv_pm_restore_thaw(struct device *dev)
 {
-	struct iucv_sock *iucv;
 	struct sock *sk;
 	struct hlist_node *node;
 
@@ -199,7 +198,6 @@ static int afiucv_pm_restore_thaw(struct
 #endif
 	read_lock(&iucv_sk_list.lock);
 	sk_for_each(sk, node, &iucv_sk_list.head) {
-		iucv = iucv_sk(sk);
 		switch (sk->sk_state) {
 		case IUCV_CONNECTED:
 			sk->sk_err = EPIPE;
@@ -381,7 +379,6 @@ static void iucv_sock_close(struct sock
 {
 	unsigned char user_data[16];
 	struct iucv_sock *iucv = iucv_sk(sk);
-	int err;
 	unsigned long timeo;
 
 	iucv_sock_clear_timer(sk);
@@ -394,8 +391,6 @@ static void iucv_sock_close(struct sock
 
 	case IUCV_CONNECTED:
 	case IUCV_DISCONN:
-		err = 0;
-
 		sk->sk_state = IUCV_CLOSING;
 		sk->sk_state_change(sk);
 
@@ -404,7 +399,7 @@ static void iucv_sock_close(struct sock
 				timeo = sk->sk_lingertime;
 			else
 				timeo = IUCV_DISCONN_TIMEOUT;
-			err = iucv_sock_wait(sk,
+			iucv_sock_wait(sk,
 					iucv_sock_in_state(sk, IUCV_CLOSED, 0),
 					timeo);
 		}
@@ -417,7 +412,7 @@ static void iucv_sock_close(struct sock
 			low_nmcpy(user_data, iucv->src_name);
 			high_nmcpy(user_data, iucv->dst_name);
 			ASCEBC(user_data, sizeof(user_data));
-			err = iucv_path_sever(iucv->path, user_data);
+			iucv_path_sever(iucv->path, user_data);
 			iucv_path_free(iucv->path);
 			iucv->path = NULL;
 		}

