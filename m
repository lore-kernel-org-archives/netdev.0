From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: [PATCH] SUNRPC: Strip __KERNEL__ testing from unexported headers.
Date: Tue, 1 Apr 2008 22:03:39 -0400 (EDT)
Message-ID: <alpine.LFD.1.00.0804012202260.11223@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:50989 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbYDBCDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 22:03:43 -0400
Received: from cpe001d60ad7267-cm001225dbafb6.cpe.net.cable.rogers.com ([99.236.100.208] helo=crashcourse.ca)
	by astoria.ccjclearline.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.68)
	(envelope-from <rpjday@crashcourse.ca>)
	id 1JgsKD-0005tx-Nr
	for netdev@vger.kernel.org; Tue, 01 Apr 2008 22:03:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

  not compile tested since it seemed fairly straightforward.

 include/linux/sunrpc/auth.h        |    3 ---
 include/linux/sunrpc/auth_gss.h    |    3 ---
 include/linux/sunrpc/clnt.h        |    3 ---
 include/linux/sunrpc/gss_api.h     |    2 --
 include/linux/sunrpc/gss_err.h     |    3 ---
 include/linux/sunrpc/msg_prot.h    |    3 ---
 include/linux/sunrpc/rpc_pipe_fs.h |    3 ---
 include/linux/sunrpc/svcauth.h     |    4 ----
 include/linux/sunrpc/svcauth_gss.h |    2 --
 include/linux/sunrpc/xdr.h         |    4 ----
 include/linux/sunrpc/xprt.h        |    4 ----
 include/linux/sunrpc/xprtsock.h    |    4 ----
 12 files changed, 38 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 7a69ca3..eac1d6f 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -9,8 +9,6 @@
 #ifndef _LINUX_SUNRPC_AUTH_H
 #define _LINUX_SUNRPC_AUTH_H

-#ifdef __KERNEL__
-
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/xdr.h>
@@ -158,5 +156,4 @@ struct rpc_cred *	get_rpccred(struct rpc_cred *cred)
 	return cred;
 }

-#endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_AUTH_H */
diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index 67658e1..a7341fe 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -14,7 +14,6 @@
 #ifndef _LINUX_SUNRPC_AUTH_GSS_H
 #define _LINUX_SUNRPC_AUTH_GSS_H

-#ifdef __KERNEL__
 #include <linux/sunrpc/auth.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/gss_api.h>
@@ -86,6 +85,4 @@ struct gss_cred {
 	struct gss_upcall_msg	*gc_upcall;
 };

-#endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_AUTH_GSS_H */
-
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 129a86e..e9f78df 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -93,8 +93,6 @@ struct rpc_procinfo {
 	char *			p_name;		/* name of procedure */
 };

-#ifdef __KERNEL__
-
 struct rpc_create_args {
 	int			protocol;
 	struct sockaddr		*address;
@@ -141,5 +139,4 @@ void		rpc_force_rebind(struct rpc_clnt *);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);

-#endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 459c5fc..593d0d9 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -14,7 +14,6 @@
 #ifndef _LINUX_SUNRPC_GSS_API_H
 #define _LINUX_SUNRPC_GSS_API_H

-#ifdef __KERNEL__
 #include <linux/sunrpc/xdr.h>
 #include <linux/uio.h>

@@ -131,6 +130,5 @@ struct gss_api_mech * gss_mech_get(struct gss_api_mech *);
  * corresponding call to gss_mech_put. */
 void gss_mech_put(struct gss_api_mech *);

-#endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_GSS_API_H */

diff --git a/include/linux/sunrpc/gss_err.h b/include/linux/sunrpc/gss_err.h
index a680786..b73c329 100644
--- a/include/linux/sunrpc/gss_err.h
+++ b/include/linux/sunrpc/gss_err.h
@@ -34,8 +34,6 @@
 #ifndef _LINUX_SUNRPC_GSS_ERR_H
 #define _LINUX_SUNRPC_GSS_ERR_H

-#ifdef __KERNEL__
-
 typedef unsigned int OM_uint32;

 /*
@@ -163,5 +161,4 @@ typedef unsigned int OM_uint32;
 /* XXXX This is a necessary evil until the spec is fixed */
 #define GSS_S_CRED_UNAVAIL GSS_S_FAILURE

-#endif /* __KERNEL__ */
 #endif /* __LINUX_SUNRPC_GSS_ERR_H */
diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index 70df4f1..43394a7 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -7,8 +7,6 @@
 #ifndef _LINUX_SUNRPC_MSGPROT_H_
 #define _LINUX_SUNRPC_MSGPROT_H_

-#ifdef __KERNEL__ /* user programs should get these from the rpc header files */
-
 #define RPC_VERSION 2

 /* size of an XDR encoding unit in bytes, i.e. 32bit */
@@ -191,5 +189,4 @@ typedef __be32	rpc_fraghdr;
  */
 #define RPCBIND_MAXUADDRLEN	(56u)

-#endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_MSGPROT_H_ */
diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 51b977a..c7ee15d 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -1,8 +1,6 @@
 #ifndef _LINUX_SUNRPC_RPC_PIPE_FS_H
 #define _LINUX_SUNRPC_RPC_PIPE_FS_H

-#ifdef __KERNEL__
-
 struct rpc_pipe_msg {
 	struct list_head list;
 	void *data;
@@ -53,4 +51,3 @@ extern int register_rpc_pipefs(void);
 extern void unregister_rpc_pipefs(void);

 #endif
-#endif
diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index 22e1ef8..6e6a1da 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -9,8 +9,6 @@
 #ifndef _LINUX_SUNRPC_SVCAUTH_H_
 #define _LINUX_SUNRPC_SVCAUTH_H_

-#ifdef __KERNEL__
-
 #include <linux/string.h>
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/cache.h>
@@ -166,6 +164,4 @@ static inline unsigned long hash_mem(char *buf, int length, int bits)
 	return hash >> (BITS_PER_LONG - bits);
 }

-#endif /* __KERNEL__ */
-
 #endif /* _LINUX_SUNRPC_SVCAUTH_H_ */
diff --git a/include/linux/sunrpc/svcauth_gss.h b/include/linux/sunrpc/svcauth_gss.h
index 417a1de..4ea40e4 100644
--- a/include/linux/sunrpc/svcauth_gss.h
+++ b/include/linux/sunrpc/svcauth_gss.h
@@ -11,7 +11,6 @@
 #ifndef _LINUX_SUNRPC_SVCAUTH_GSS_H
 #define _LINUX_SUNRPC_SVCAUTH_GSS_H

-#ifdef __KERNEL__
 #include <linux/sched.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
@@ -24,5 +23,4 @@ void gss_svc_shutdown(void);
 int svcauth_gss_register_pseudoflavor(u32 pseudoflavor, char * name);
 u32 svcauth_gss_flavor(struct auth_domain *dom);

-#endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_SVCAUTH_GSS_H */
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index e4057d7..2285c7b 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -7,8 +7,6 @@
 #ifndef _SUNRPC_XDR_H_
 #define _SUNRPC_XDR_H_

-#ifdef __KERNEL__
-
 #include <linux/uio.h>
 #include <asm/byteorder.h>
 #include <linux/scatterlist.h>
@@ -220,6 +218,4 @@ extern void xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
 extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
 extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);

-#endif /* __KERNEL__ */
-
 #endif /* _SUNRPC_XDR_H_ */
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index b3ff9a8..a33ff50 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -17,8 +17,6 @@
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/msg_prot.h>

-#ifdef __KERNEL__
-
 #define RPC_MIN_SLOT_TABLE	(2U)
 #define RPC_DEF_SLOT_TABLE	(16U)
 #define RPC_MAX_SLOT_TABLE	(128U)
@@ -322,6 +320,4 @@ static inline int xprt_test_and_set_binding(struct rpc_xprt *xprt)
 	return test_and_set_bit(XPRT_BINDING, &xprt->state);
 }

-#endif /* __KERNEL__*/
-
 #endif /* _LINUX_SUNRPC_XPRT_H */
diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index c2a46c4..f9f76d0 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -7,8 +7,6 @@
 #ifndef _LINUX_SUNRPC_XPRTSOCK_H
 #define _LINUX_SUNRPC_XPRTSOCK_H

-#ifdef __KERNEL__
-
 int		init_socket_xprt(void);
 void		cleanup_socket_xprt(void);

@@ -40,6 +38,4 @@ extern unsigned int xprt_max_resvport;
 #define RPC_DEF_MIN_RESVPORT	(665U)
 #define RPC_DEF_MAX_RESVPORT	(1023U)

-#endif /* __KERNEL__ */
-
 #endif /* _LINUX_SUNRPC_XPRTSOCK_H */

========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
========================================================================
