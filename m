From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 4/7] [PATCH] af_iucv: fix race in __iucv_sock_wait()
Date: Wed, 16 Sep 2009 16:37:25 +0200
Message-ID: <20090916144304.540352000@linux.vnet.ibm.com>
References: <20090916143721.863799000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:48390 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbZIPOnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 10:43:03 -0400
Content-Disposition: inline; filename=604-af_iucv-sock-wait-race.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

Moving prepare_to_wait before the condition to avoid a race between
schedule_timeout and wake up.
The race can appear during iucv_sock_connect() and iucv_callback_connack().

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/af_iucv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- linux-2.6-uschi.orig/net/iucv/af_iucv.c
+++ linux-2.6-uschi/net/iucv/af_iucv.c
@@ -59,8 +59,8 @@ do {									\
 	DEFINE_WAIT(__wait);						\
 	long __timeo = timeo;						\
 	ret = 0;							\
+	prepare_to_wait(sk->sk_sleep, &__wait, TASK_INTERRUPTIBLE);	\
 	while (!(condition)) {						\
-		prepare_to_wait(sk->sk_sleep, &__wait, TASK_INTERRUPTIBLE); \
 		if (!__timeo) {						\
 			ret = -EAGAIN;					\
 			break;						\

