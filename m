From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] make sendmsg return EDESTADDRREQ if socket is not connected and daddr was not specified
Date: Fri, 11 Jul 2003 01:32:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710233223.GA30577@rei.rakuen>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello

Another 1003.1 fix:

[EDESTADDRREQ]
    The socket is not connection-mode and does not have its peer
    address set, and no destination address was specified.

fixes sendmsg in ipv{4,6}/{raw,udp}

 -- thomas


Index: net/ipv4/raw.c
===================================================================
RCS file: /cvs/tgr/linux-25/net/ipv4/raw.c,v
retrieving revision 1.1.1.2
diff -u -r1.1.1.2 raw.c
--- net/ipv4/raw.c	10 Jul 2003 22:58:45 -0000	1.1.1.2
+++ net/ipv4/raw.c	10 Jul 2003 23:18:04 -0000
@@ -383,7 +383,7 @@
 		 * IP_HDRINCL is much more convenient.
 		 */
 	} else {
-		err = -EINVAL;
+		err = -EDESTADDRREQ;
 		if (sk->sk_state != TCP_ESTABLISHED) 
 			goto out;
 		daddr = inet->daddr;
Index: net/ipv4/udp.c
===================================================================
RCS file: /cvs/tgr/linux-25/net/ipv4/udp.c,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 udp.c
--- net/ipv4/udp.c	9 Jul 2003 18:42:29 -0000	1.1.1.1
+++ net/ipv4/udp.c	10 Jul 2003 23:18:04 -0000
@@ -540,7 +540,7 @@
 			return -EINVAL;
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
-			return -ENOTCONN;
+			return -EDESTADDRREQ;
 		daddr = inet->daddr;
 		dport = inet->dport;
 		/* Open fast path for connected socket.
Index: net/ipv6/raw.c
===================================================================
RCS file: /cvs/tgr/linux-25/net/ipv6/raw.c,v
retrieving revision 1.1.1.2
diff -u -r1.1.1.2 raw.c
--- net/ipv6/raw.c	10 Jul 2003 22:58:50 -0000	1.1.1.2
+++ net/ipv6/raw.c	10 Jul 2003 23:18:04 -0000
@@ -602,7 +602,7 @@
 			fl.oif = sin6->sin6_scope_id;
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED) 
-			return(-EINVAL);
+			return -EDESTADDRREQ;
 		
 		proto = inet->num;
 		daddr = &np->daddr;
Index: net/ipv6/udp.c
===================================================================
RCS file: /cvs/tgr/linux-25/net/ipv6/udp.c,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 udp.c
--- net/ipv6/udp.c	9 Jul 2003 18:42:35 -0000	1.1.1.1
+++ net/ipv6/udp.c	10 Jul 2003 23:18:04 -0000
@@ -862,7 +862,7 @@
 			fl.oif = sin6->sin6_scope_id;
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
-			return -ENOTCONN;
+			return -EDESTADDRREQ;
 
 		up->dport = inet->dport;
 		daddr = &np->daddr;
