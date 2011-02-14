From: Bernard Pidoux <bernard.pidoux@upmc.fr>
Subject: Re: [PATCH] [ROSE] AX25 packet routing improvement
Date: Mon, 14 Feb 2011 18:52:09 +0100
Message-ID: <4D596BC9.4030509@upmc.fr>
References: <4CF78B70.4060907@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010109000901070501070309"
Cc: ralf@linux-mips.org, davem@davemloft.net,
	Bernard Pidoux F6BVP <f6bvp@free.fr>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva145.upmc.fr ([134.157.0.145]:57861 "EHLO shiva.upmc.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752007Ab1BNSGk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Feb 2011 13:06:40 -0500
In-Reply-To: <4CF78B70.4060907@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010109000901070501070309
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

Here is a second try for this patch that completes the previous one.

[PATCH] [ROSE] [AX25] finding routes simplification

With previous patch, rose_get_neigh() routine
investigates the full list of neighbor nodes
until it finds or not an already connected node whether
it is called locally or through a level 3 transit frame.
If no routes are opened through an adjacent connected node
then a classical connect request is attempted.

Then there is no more reason for an extra loop such
as the one removed by this patch.

Signed-off-by: Bernard Pidoux <f6bvp@free.fr>

--------------010109000901070501070309
Content-Type: text/x-patch;
 name="af_rose.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="af_rose.patch"

--- a/net/rose/af_rose.c	2010-12-09 23:17:27.000000000 +0100
+++ b/net/rose/af_rose.c	2010-12-19 15:06:44.399455216 +0100
@@ -803,7 +803,6 @@
 
 		rose_insert_socket(sk);		/* Finish the bind */
 	}
-rose_try_next_neigh:
 	rose->dest_addr   = addr->srose_addr;
 	rose->dest_call   = addr->srose_call;
 	rose->rand        = ((long)rose & 0xFFFF) + rose->lci;
@@ -865,12 +864,6 @@
 	}
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
-	/* Try next neighbour */
-		rose->neighbour = rose_get_neigh(&addr->srose_addr, &cause, &diagnostic, 0);
-		if (rose->neighbour)
-			goto rose_try_next_neigh;
-
-		/* No more neighbours */
 		sock->state = SS_UNCONNECTED;
 		err = sock_error(sk);	/* Always set at this point */
 		goto out_release;


--------------010109000901070501070309--
