From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Check for SOL_SOCKET in compat_sys_getsockopt
Date: Mon, 3 Jan 2005 15:33:06 +0100
Message-ID: <20050103143306.GG25446@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IiVenqGWf+H9Y6IX"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--IiVenqGWf+H9Y6IX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

compat_sys_getsockopt checks for SO_RCVTIMEO/SO_SNDTIMEO without
making sure that the level is actually SOL_SOCKET. This can break
getsockopt() requests for other protocols.

Cheers, and a happy new year to everyone!
Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"

--IiVenqGWf+H9Y6IX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=setsockopt-compat

Subject: check for SOL_SOCKET in compat_sys_getsocket

compat_sys_getsockopt checks for SO_RCVTIMEO/SO_SNDTIMEO without
making sure that the level is actually SOL_SOCKET. This can break
getsockopt() requests for other protocols.

Signed-off-by: Olaf Kirch <okir@suse.de>

Index: linux-2.6.9/net/compat.c
===================================================================
--- linux-2.6.9.orig/net/compat.c	2005-01-03 15:25:11.000000000 +0100
+++ linux-2.6.9/net/compat.c	2005-01-03 15:25:29.000000000 +0100
@@ -507,7 +507,8 @@ static int do_get_sock_timeout(int fd, i
 asmlinkage long compat_sys_getsockopt(int fd, int level, int optname,
 				char __user *optval, int __user *optlen)
 {
-	if (optname == SO_RCVTIMEO || optname == SO_SNDTIMEO)
+	if (level == SOL_SOCKET &&
+	    (optname == SO_RCVTIMEO || optname == SO_SNDTIMEO))
 		return do_get_sock_timeout(fd, level, optname, optval, optlen);
 	return sys_getsockopt(fd, level, optname, optval, optlen);
 }

--IiVenqGWf+H9Y6IX--
