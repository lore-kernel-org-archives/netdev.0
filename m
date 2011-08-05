From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 2/3] net: Cap number of elements for sendmmsg
Date: Fri, 05 Aug 2011 10:07:39 +1000
Message-ID: <20110805000822.327910762@samba.org>
References: <20110805000737.743684961@samba.org>
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp, davem@davemloft.net,
	eparis@parisplace.org, casey@schaufler-ca.com, mjt@tls.msk.ru
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline; filename=cap_sendmmsg
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To limit the amount of time we can spend in sendmmsg, cap the
number of elements to UIO_MAXIOV (currently 1024). 

For error handling an application using sendmmsg needs to retry at
the first unsent message, so capping is simpler and requires less
application logic than returning EINVAL.

Signed-off-by: Anton Blanchard <anton@samba.org>
Cc: stable <stable@kernel.org> [3.0+]
---

Index: linux-net/net/socket.c
===================================================================
--- linux-net.orig/net/socket.c	2011-08-04 20:16:58.667081839 +1000
+++ linux-net/net/socket.c	2011-08-04 20:37:32.399602006 +1000
@@ -1999,6 +1999,9 @@ int __sys_sendmmsg(int fd, struct mmsghd
 	struct compat_mmsghdr __user *compat_entry;
 	struct msghdr msg_sys;
 
+	if (vlen > UIO_MAXIOV)
+		vlen = UIO_MAXIOV;
+
 	datagrams = 0;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);


