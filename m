From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: CONFIG_COMPAT redux
Date: Mon, 1 Feb 2010 21:44:19 +0200
Message-ID: <20100201194418.GB21315@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:45088 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755910Ab0BATo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 14:44:26 -0500
Received: by fxm20 with SMTP id 20so4639669fxm.21
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2010 11:44:24 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ifdef out
	struct proto_ops::compat_ioctl
	struct proto_ops::compat_setsockopt
	struct proto_ops::compat_getsockopt
to make structures smaller on COMPAT=n kernels.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/net.h |    4 ++++
 1 file changed, 4 insertions(+)

--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -174,18 +174,22 @@ struct proto_ops {
 				      struct poll_table_struct *wait);
 	int		(*ioctl)     (struct socket *sock, unsigned int cmd,
 				      unsigned long arg);
+#ifdef CONFIG_COMPAT
 	int	 	(*compat_ioctl) (struct socket *sock, unsigned int cmd,
 				      unsigned long arg);
+#endif
 	int		(*listen)    (struct socket *sock, int len);
 	int		(*shutdown)  (struct socket *sock, int flags);
 	int		(*setsockopt)(struct socket *sock, int level,
 				      int optname, char __user *optval, unsigned int optlen);
 	int		(*getsockopt)(struct socket *sock, int level,
 				      int optname, char __user *optval, int __user *optlen);
+#ifdef CONFIG_COMPAT
 	int		(*compat_setsockopt)(struct socket *sock, int level,
 				      int optname, char __user *optval, unsigned int optlen);
 	int		(*compat_getsockopt)(struct socket *sock, int level,
 				      int optname, char __user *optval, int __user *optlen);
+#endif
 	int		(*sendmsg)   (struct kiocb *iocb, struct socket *sock,
 				      struct msghdr *m, size_t total_len);
 	int		(*recvmsg)   (struct kiocb *iocb, struct socket *sock,
