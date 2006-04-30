From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: Re: [PATCH 3/3] Eleminate HZ from ROSE kernel interfaces
Date: Sun, 30 Apr 2006 11:35:54 +0200
Message-ID: <445484FA.6050008@ccr.jussieu.fr>
References: <20060429141924.GA2941@linux-mips.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090802090601000706050501"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: Ralf Baechle <ralf@linux-mips.org>
In-Reply-To: <20060429141924.GA2941@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090802090601000706050501
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Ralf Baechle wrote :

> Index: linux-net.git/net/rose/af_rose.c
> ===================================================================
> --- linux-net.git.orig/net/rose/af_rose.c	2006-04-29 01:54:21.000000000 +0100
> +++ linux-net.git/net/rose/af_rose.c	2006-04-29 11:37:34.000000000 +0100

While patching af_rose.c, would you consider the following patch 
ROSE/FPAC users have introduced a year ago with good success.

73 de Bernard, f6bvp

http://f6bvp.org
http://rose.fpac.free.fr/MINI-HOWTO/
http://rose.fpac.free.fr/MINI-HOWTO-FR/


--------------090802090601000706050501
Content-Type: text/x-patch;
 name="af_rose.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="af_rose.diff"

--- linux/net/rose/af_rose.c.orig	2006-04-30 11:30:48.000000000 +0200
+++ linux/net/rose/af_rose.c	2006-04-30 11:27:35.000000000 +0200
@@ -753,6 +753,7 @@
 
 		rose_insert_socket(sk);		/* Finish the bind */
 	}
+rose_try_next_neigh:
 	rose->dest_addr   = addr->srose_addr;
 	rose->dest_call   = addr->srose_call;
 	rose->rand        = ((long)rose & 0xFFFF) + rose->lci;
@@ -810,6 +811,11 @@
 	}
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
+	/* Try next neighbour */
+		rose->neighbour = rose_get_neigh(&addr->srose_addr, &cause, &diagnostic);
+		if (rose->neighbour)
+			goto rose_try_next_neigh;
+	/* No more neighbour */
 		sock->state = SS_UNCONNECTED;
 		return sock_error(sk);	/* Always set at this point */
 	}

--------------090802090601000706050501--
