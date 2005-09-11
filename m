From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH  4/12] Remove useless tests
Date: Sun, 11 Sep 2005 23:18:58 +0100
Message-ID: <20050911221858.GA9294@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove error tests that have already been performed by the caller.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 net/ax25/af_ax25.c     |    6 +-----
 net/netrom/af_netrom.c |    4 +---
 net/rose/af_rose.c     |    4 +---
 3 files changed, 3 insertions(+), 11 deletions(-)

Index: linux-cvs/net/netrom/af_netrom.c
===================================================================
--- linux-cvs.orig/net/netrom/af_netrom.c
+++ linux-cvs/net/netrom/af_netrom.c
@@ -1187,9 +1187,7 @@ static int nr_ioctl(struct socket *sock,
 	}
 
 	case SIOCGSTAMP:
-		ret = -EINVAL;
-		if (sk != NULL)
-			ret = sock_get_timestamp(sk, argp);
+		ret = sock_get_timestamp(sk, argp);
 		release_sock(sk);
 		return ret;
 
Index: linux-cvs/net/ax25/af_ax25.c
===================================================================
--- linux-cvs.orig/net/ax25/af_ax25.c
+++ linux-cvs/net/ax25/af_ax25.c
@@ -1700,11 +1700,7 @@ static int ax25_ioctl(struct socket *soc
 	}
 
 	case SIOCGSTAMP:
-		if (sk != NULL) {
-			res = sock_get_timestamp(sk, argp);
-			break;
-	 	}
-		res = -EINVAL;
+		res = sock_get_timestamp(sk, argp);
 		break;
 
 	case SIOCAX25ADDUID:	/* Add a uid to the uid/call map table */
Index: linux-cvs/net/rose/af_rose.c
===================================================================
--- linux-cvs.orig/net/rose/af_rose.c
+++ linux-cvs/net/rose/af_rose.c
@@ -1256,9 +1256,7 @@ static int rose_ioctl(struct socket *soc
 	}
 
 	case SIOCGSTAMP:
-		if (sk != NULL) 
-			return sock_get_timestamp(sk, (struct timeval __user *)argp);
-		return -EINVAL;
+		return sock_get_timestamp(sk, (struct timeval __user *)argp);
 
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
