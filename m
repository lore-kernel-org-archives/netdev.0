From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Problem with recent CMSG_COMPAT_OK fix
Date: Tue, 4 Jan 2005 17:59:34 +0100
Message-ID: <20050104165934.GJ7761@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="T4sUOijqQbZv57TR"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

The recent fixes for cmsg_len handling seem to break 32bit compatibility
at least on x86_64. The new CMSG_COMPAT_OK macro requires that cmsg_len
is greater or equal the size of struct cmsghdr, which is the 64bit
version of the struct.  The code should really check against the size
of struct compat_cmsghdr.

Signed-off-by: Olaf Kirch <okir@suse.de>

--- linux-2.6.10/net/compat.c.orig	2005-01-04 13:51:49.000000000 +0100
+++ linux-2.6.10/net/compat.c	2005-01-04 16:53:38.000000000 +0100
@@ -125,7 +125,7 @@
 	 (struct compat_cmsghdr __user *)NULL)
 
 #define CMSG_COMPAT_OK(ucmlen, ucmsg, mhdr) \
-	((ucmlen) >= sizeof(struct cmsghdr) && \
+	((ucmlen) >= sizeof(struct compat_cmsghdr) && \
 	 (ucmlen) <= (unsigned long) \
 	 ((mhdr)->msg_controllen - \
 	  ((char *)(ucmsg) - (char *)(mhdr)->msg_control)))

-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"

--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=cmsg-compat-signedness-fix-fix

From: Olaf Kirch <okir@suse.de>
Subject: Fix cmsg_len checks in 32bit compat mode
References: 49517 - LTC13227

The recent fixes for cmsg_len handling seem to break 32bit compatibility
at least on x86_64. The new CMSG_COMPAT_OK macro requires that cmsg_len
is greater or equal the size of struct cmsghdr, which is the 64bit
version of the struct.  The code should really check against the size
of struct compat_cmsghdr.

Signed-off-by: Olaf Kirch <okir@suse.de>

--- linux-2.6.10/net/compat.c.orig	2005-01-04 13:51:49.000000000 +0100
+++ linux-2.6.10/net/compat.c	2005-01-04 16:53:38.000000000 +0100
@@ -125,7 +125,7 @@
 	 (struct compat_cmsghdr __user *)NULL)
 
 #define CMSG_COMPAT_OK(ucmlen, ucmsg, mhdr) \
-	((ucmlen) >= sizeof(struct cmsghdr) && \
+	((ucmlen) >= sizeof(struct compat_cmsghdr) && \
 	 (ucmlen) <= (unsigned long) \
 	 ((mhdr)->msg_controllen - \
 	  ((char *)(ucmsg) - (char *)(mhdr)->msg_control)))

--T4sUOijqQbZv57TR--
