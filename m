From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: [PATCH] [ROSE] reverts commits d85838c55d836c33077344fab424f200f2827d84
Date: Fri, 14 Dec 2007 22:58:28 +0100
Message-ID: <4762FC84.5000806@ccr.jussieu.fr>
References: <20071003185413.GA16242@martell.zuzino.mipt.ru> <20071007.234433.21388460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000904070309020208010703"
Cc: adobriyan@gmail.com, ralf@linux-mips.org, netdev@vger.kernel.org,
	Jarek Poplawski <jarkao2@o2.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix1-g20.free.fr ([212.27.60.42]:48201 "EHLO
	postfix1-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754897AbXLNWxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 17:53:42 -0500
Received: from smtp5-g19.free.fr (smtp5-g19.free.fr [212.27.42.35])
	by postfix1-g20.free.fr (Postfix) with ESMTP id 1F2AF203028F
	for <netdev@vger.kernel.org>; Fri, 14 Dec 2007 23:53:41 +0100 (CET)
In-Reply-To: <20071007.234433.21388460.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000904070309020208010703
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

This patch against 2.6.24-rc5 reverts commit 
d85838c55d836c33077344fab424f200f2827d84,
that was supposed to detect all connected ROSE node neighbors.
Actually the loop was misplaced and the node list was not completely
explored.Next sublitted patch gives a solution.

signed off by Bernard Pidoux, f6bvp@amsat.org



--------------000904070309020208010703
Content-Type: text/plain;
 name="rose-2.6.24-rc5.patch1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rose-2.6.24-rc5.patch1"

--- linux-2.6.24-rc5/net/rose/af_rose.c	2007-12-11 04:48:43.000000000 +0100
+++ b/net/rose/af_rose.c	2007-12-14 14:09:40.000000000 +0100
@@ -782,7 +782,6 @@
 
 		rose_insert_socket(sk);		/* Finish the bind */
 	}
-rose_try_next_neigh:
 	rose->dest_addr   = addr->srose_addr;
 	rose->dest_call   = addr->srose_call;
 	rose->rand        = ((long)rose & 0xFFFF) + rose->lci;
@@ -844,12 +843,6 @@
 	}
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
-	/* Try next neighbour */
-		rose->neighbour = rose_get_neigh(&addr->srose_addr, &cause, &diagnostic);
-		if (rose->neighbour)
-			goto rose_try_next_neigh;
-
-		/* No more neighbours */
 		sock->state = SS_UNCONNECTED;
 		err = sock_error(sk);	/* Always set at this point */
 		goto out_release;

--------------000904070309020208010703--

