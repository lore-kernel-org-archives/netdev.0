From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] make {send|recv}msg return code 1003.1 compatible
Date: Wed, 9 Jul 2003 21:36:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709193628.GR2702@rei.rakuen>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello

1003.1 says:

[EMSGSIZE]
    The msg_iovlen member of the msghdr structure pointed to by
    message is less than or equal to 0, or is greater than
    {IOV_MAX}.

The patch changes the return code of {send|recv}msg from EINVAL
to EMSGSIZE.

 -- thomas


Index: net/socket.c
===================================================================
RCS file: /cvs/tgr/linux-25/net/socket.c,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 socket.c
--- net/socket.c	9 Jul 2003 18:42:29 -0000	1.1.1.1
+++ net/socket.c	9 Jul 2003 19:17:29 -0000
@@ -1614,7 +1614,7 @@
 		goto out;
 
 	/* do not move before msg_sys is valid */
-	err = -EINVAL;
+	err = -EMSGSIZE;
 	if (msg_sys.msg_iovlen > UIO_MAXIOV)
 		goto out_put;
 
@@ -1713,7 +1713,7 @@
 	if (!sock)
 		goto out;
 
-	err = -EINVAL;
+	err = -EMSGSIZE;
 	if (msg_sys.msg_iovlen > UIO_MAXIOV)
 		goto out_put;
 	
