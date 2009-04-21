From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 06/13] [PATCH] af_iucv: Test additional sk states in iucv_sock_shutdown
Date: Tue, 21 Apr 2009 12:35:03 +0200
Message-ID: <20090421103705.862918000@linux.vnet.ibm.com>
References: <20090421103457.965299000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:35697 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753911AbZDUKhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 06:37:07 -0400
Content-Disposition: inline; filename=606-af_iucv-sk-states.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

Add few more sk states in iucv_sock_shutdown().

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/af_iucv.c |    3 +++
 1 file changed, 3 insertions(+)

Index: net-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6-uschi/net/iucv/af_iucv.c
@@ -939,6 +939,9 @@ static int iucv_sock_shutdown(struct soc
 
 	lock_sock(sk);
 	switch (sk->sk_state) {
+	case IUCV_DISCONN:
+	case IUCV_CLOSING:
+	case IUCV_SEVERED:
 	case IUCV_CLOSED:
 		err = -ENOTCONN;
 		goto fail;

