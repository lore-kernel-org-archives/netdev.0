From: James Morris <jmorris@namei.org>
Subject: Re: [Patch 1/1] AF_UNIX Datagram getpeersec [Updated]
Date: Tue, 27 Jun 2006 03:14:59 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606270311210.30073@d.namei>
References: <20060627052255.GA1311@jiayuguan.watson.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	jmorris@redhat.com, chrisw@osdl.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Smalley <sds@tycho.nsa.gov>, tjaeger@cse.psu.edu,
	Andrew Morton <akpm@osdl.org>, latten@austin.ibm.com,
	sergeh@us.ibm.com, gcwilson@us.ibm.com, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:47548 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932549AbWF0HPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 03:15:03 -0400
To: Catherine Zhang <cxzhang@watson.ibm.com>
In-Reply-To: <20060627052255.GA1311@jiayuguan.watson.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Jun 2006, Catherine Zhang wrote:

> Again, comments are welcome!

Got this warning while compiling.

security/selinux/exports.c: In function #selinux_get_sock_sid#:
security/selinux/exports.c:79: warning: passing argument 1 of #SOCK_INODE# discards qualifiers from pointer target type

In the interests of time, I've fixed that warning in an updated version of 
your patch below.

Also, you've added a security field to a core kernel structure with no 
#ifdefs and also added unconditional security related code to core 
networking code.

I'll address that in a patch to follow.  Could you please test these 
updated patches?  Thanks.

If they look ok to everyone and pass your testing, I'll submit them to 
DaveM.

---


diff -purN -X dontdiff linux-2.6.p/include/asm-alpha/socket.h linux-2.6.w/include/asm-alpha/socket.h
--- linux-2.6.p/include/asm-alpha/socket.h	2006-06-21 00:02:08.000000000 -0400
+++ linux-2.6.w/include/asm-alpha/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -51,6 +51,7 @@
 #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		30
+#define SO_PASSSEC		34
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		19
diff -purN -X dontdiff linux-2.6.p/include/asm-arm/socket.h linux-2.6.w/include/asm-arm/socket.h
--- linux-2.6.p/include/asm-arm/socket.h	2006-06-21 00:02:10.000000000 -0400
+++ linux-2.6.w/include/asm-arm/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.p/include/asm-arm26/socket.h linux-2.6.w/include/asm-arm26/socket.h
--- linux-2.6.p/include/asm-arm26/socket.h	2006-06-21 00:02:10.000000000 -0400
+++ linux-2.6.w/include/asm-arm26/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.p/include/asm-cris/socket.h linux-2.6.w/include/asm-cris/socket.h
--- linux-2.6.p/include/asm-cris/socket.h	2006-06-21 00:02:11.000000000 -0400
+++ linux-2.6.w/include/asm-cris/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -50,6 +50,7 @@
 #define SO_ACCEPTCONN          30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
 
diff -purN -X dontdiff linux-2.6.p/include/asm-frv/socket.h linux-2.6.w/include/asm-frv/socket.h
--- linux-2.6.p/include/asm-frv/socket.h	2006-06-21 00:02:11.000000000 -0400
+++ linux-2.6.w/include/asm-frv/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,6 +48,7 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
 
diff -purN -X dontdiff linux-2.6.p/include/asm-h8300/socket.h linux-2.6.w/include/asm-h8300/socket.h
--- linux-2.6.p/include/asm-h8300/socket.h	2006-06-21 00:02:11.000000000 -0400
+++ linux-2.6.w/include/asm-h8300/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.p/include/asm-i386/socket.h linux-2.6.w/include/asm-i386/socket.h
--- linux-2.6.p/include/asm-i386/socket.h	2006-06-21 00:02:12.000000000 -0400
+++ linux-2.6.w/include/asm-i386/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.p/include/asm-ia64/socket.h linux-2.6.w/include/asm-ia64/socket.h
--- linux-2.6.p/include/asm-ia64/socket.h	2006-06-21 00:02:12.000000000 -0400
+++ linux-2.6.w/include/asm-ia64/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -57,5 +57,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_IA64_SOCKET_H */
diff -purN -X dontdiff linux-2.6.p/include/asm-m32r/socket.h linux-2.6.w/include/asm-m32r/socket.h
--- linux-2.6.p/include/asm-m32r/socket.h	2006-06-21 00:02:13.000000000 -0400
+++ linux-2.6.w/include/asm-m32r/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_M32R_SOCKET_H */
diff -purN -X dontdiff linux-2.6.p/include/asm-m68k/socket.h linux-2.6.w/include/asm-m68k/socket.h
--- linux-2.6.p/include/asm-m68k/socket.h	2006-06-21 00:02:13.000000000 -0400
+++ linux-2.6.w/include/asm-m68k/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.p/include/asm-mips/socket.h linux-2.6.w/include/asm-mips/socket.h
--- linux-2.6.p/include/asm-mips/socket.h	2006-06-21 00:02:15.000000000 -0400
+++ linux-2.6.w/include/asm-mips/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -69,6 +69,7 @@ To add: #define SO_REUSEPORT 0x0200	/* A
 #define SO_PEERSEC		30
 #define SO_SNDBUFFORCE		31
 #define SO_RCVBUFFORCE		33
+#define SO_PASSSEC		34
 
 #ifdef __KERNEL__
 
diff -purN -X dontdiff linux-2.6.p/include/asm-parisc/socket.h linux-2.6.w/include/asm-parisc/socket.h
--- linux-2.6.p/include/asm-parisc/socket.h	2006-06-21 00:02:15.000000000 -0400
+++ linux-2.6.w/include/asm-parisc/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		0x401c
 
 #define SO_PEERSEC		0x401d
+#define SO_PASSSEC		0x401e
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.p/include/asm-powerpc/socket.h linux-2.6.w/include/asm-powerpc/socket.h
--- linux-2.6.p/include/asm-powerpc/socket.h	2006-06-21 00:02:16.000000000 -0400
+++ linux-2.6.w/include/asm-powerpc/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -55,5 +55,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff -purN -X dontdiff linux-2.6.p/include/asm-s390/socket.h linux-2.6.w/include/asm-s390/socket.h
--- linux-2.6.p/include/asm-s390/socket.h	2006-06-21 00:02:17.000000000 -0400
+++ linux-2.6.w/include/asm-s390/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -56,5 +56,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.p/include/asm-sh/socket.h linux-2.6.w/include/asm-sh/socket.h
--- linux-2.6.p/include/asm-sh/socket.h	2006-06-21 00:02:17.000000000 -0400
+++ linux-2.6.w/include/asm-sh/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* __ASM_SH_SOCKET_H */
diff -purN -X dontdiff linux-2.6.p/include/asm-sparc/socket.h linux-2.6.w/include/asm-sparc/socket.h
--- linux-2.6.p/include/asm-sparc/socket.h	2006-06-21 00:02:18.000000000 -0400
+++ linux-2.6.w/include/asm-sparc/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,6 +48,7 @@
 #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		0x001e
+#define SO_PASSSEC		0x001f
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff -purN -X dontdiff linux-2.6.p/include/asm-sparc64/socket.h linux-2.6.w/include/asm-sparc64/socket.h
--- linux-2.6.p/include/asm-sparc64/socket.h	2006-06-21 00:02:19.000000000 -0400
+++ linux-2.6.w/include/asm-sparc64/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,6 +48,7 @@
 #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		0x001e
+#define SO_PASSSEC		0x001f
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff -purN -X dontdiff linux-2.6.p/include/asm-v850/socket.h linux-2.6.w/include/asm-v850/socket.h
--- linux-2.6.p/include/asm-v850/socket.h	2006-06-21 00:02:20.000000000 -0400
+++ linux-2.6.w/include/asm-v850/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* __V850_SOCKET_H__ */
diff -purN -X dontdiff linux-2.6.p/include/asm-x86_64/socket.h linux-2.6.w/include/asm-x86_64/socket.h
--- linux-2.6.p/include/asm-x86_64/socket.h	2006-06-21 00:02:20.000000000 -0400
+++ linux-2.6.w/include/asm-x86_64/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.p/include/asm-xtensa/socket.h linux-2.6.w/include/asm-xtensa/socket.h
--- linux-2.6.p/include/asm-xtensa/socket.h	2006-06-21 00:02:21.000000000 -0400
+++ linux-2.6.w/include/asm-xtensa/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -59,5 +59,6 @@
 
 #define SO_ACCEPTCONN		30
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif	/* _XTENSA_SOCKET_H */
diff -purN -X dontdiff linux-2.6.p/include/linux/net.h linux-2.6.w/include/linux/net.h
--- linux-2.6.p/include/linux/net.h	2006-06-21 00:02:23.000000000 -0400
+++ linux-2.6.w/include/linux/net.h	2006-06-27 02:08:49.000000000 -0400
@@ -61,6 +61,7 @@ typedef enum {
 #define SOCK_ASYNC_WAITDATA	1
 #define SOCK_NOSPACE		2
 #define SOCK_PASSCRED		3
+#define SOCK_PASSSEC		4
 
 #ifndef ARCH_HAS_SOCKET_TYPES
 /**
diff -purN -X dontdiff linux-2.6.p/include/linux/selinux.h linux-2.6.w/include/linux/selinux.h
--- linux-2.6.p/include/linux/selinux.h	2006-06-21 00:02:23.000000000 -0400
+++ linux-2.6.w/include/linux/selinux.h	2006-06-27 02:18:47.000000000 -0400
@@ -18,6 +18,7 @@ struct selinux_audit_rule;
 struct audit_context;
 struct inode;
 struct kern_ipc_perm;
+struct socket;
 
 #ifdef CONFIG_SECURITY_SELINUX
 
@@ -119,6 +120,15 @@ void selinux_get_ipc_sid(const struct ke
 void selinux_get_task_sid(struct task_struct *tsk, u32 *sid);
 
 /**
+ *     selinux_get_sock_sid - return the SID of socket
+ *     @sock: the socket whose SID will be returned
+ *     @sid: pointer to security context ID to be filled in.
+ *
+ *     Returns nothing
+ */
+void selinux_get_sock_sid(struct socket *sock, u32 *sid);
+
+/**
  *     selinux_string_to_sid - map a security context string to a security ID
  *     @str: the security context string to be mapped
  *     @sid: ID value returned via this.
@@ -193,6 +203,11 @@ static inline void selinux_get_task_sid(
 	*sid = 0;
 }
 
+static inline void selinux_get_sock_sid(struct socket *sock, u32 *sid)
+{
+	*sid = 0;
+}
+
 static inline int selinux_string_to_sid(const char *str, u32 *sid)
 {
        *sid = 0;
diff -purN -X dontdiff linux-2.6.p/include/net/af_unix.h linux-2.6.w/include/net/af_unix.h
--- linux-2.6.p/include/net/af_unix.h	2006-06-21 00:02:24.000000000 -0400
+++ linux-2.6.w/include/net/af_unix.h	2006-06-27 02:08:49.000000000 -0400
@@ -53,10 +53,12 @@ struct unix_address {
 struct unix_skb_parms {
 	struct ucred		creds;		/* Skb credentials	*/
 	struct scm_fp_list	*fp;		/* Passed files		*/
+	char			*secdata;	/* Security context	*/
 };
 
 #define UNIXCB(skb) 	(*(struct unix_skb_parms*)&((skb)->cb))
 #define UNIXCREDS(skb)	(&UNIXCB((skb)).creds)
+#define UNIXSEC(skb)	(&UNIXCB((skb)).secdata)
 
 #define unix_state_rlock(s)	spin_lock(&unix_sk(s)->lock)
 #define unix_state_runlock(s)	spin_unlock(&unix_sk(s)->lock)
diff -purN -X dontdiff linux-2.6.p/include/net/scm.h linux-2.6.w/include/net/scm.h
--- linux-2.6.p/include/net/scm.h	2006-06-21 00:02:24.000000000 -0400
+++ linux-2.6.w/include/net/scm.h	2006-06-27 02:08:49.000000000 -0400
@@ -19,6 +19,7 @@ struct scm_cookie
 {
 	struct ucred		creds;		/* Skb credentials	*/
 	struct scm_fp_list	*fp;		/* Passed files		*/
+	char			*secdata;	/* Security context	*/
 	unsigned long		seq;		/* Connection seqno	*/
 };
 
@@ -62,6 +63,9 @@ static __inline__ void scm_recv(struct s
 	if (test_bit(SOCK_PASSCRED, &sock->flags))
 		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(scm->creds), &scm->creds);
 
+	if (test_bit(SOCK_PASSSEC, &sock->flags) && scm->secdata != NULL)
+		put_cmsg(msg, SOL_SOCKET, SCM_SECURITY, strlen(scm->secdata)+1, scm->secdata);
+
 	if (!scm->fp)
 		return;
 	
diff -purN -X dontdiff linux-2.6.p/net/core/sock.c linux-2.6.w/net/core/sock.c
--- linux-2.6.p/net/core/sock.c	2006-06-21 00:02:27.000000000 -0400
+++ linux-2.6.w/net/core/sock.c	2006-06-27 02:08:49.000000000 -0400
@@ -565,6 +565,13 @@ set_rcvbuf:
 			ret = -ENONET;
 			break;
 
+		case SO_PASSSEC:
+			if (valbool)
+				set_bit(SOCK_PASSSEC, &sock->flags);
+			else
+				clear_bit(SOCK_PASSSEC, &sock->flags);
+			break;
+
 		/* We implement the SO_SNDLOWAT etc to
 		   not be settable (1003.1g 5.3) */
 		default:
@@ -723,6 +730,10 @@ int sock_getsockopt(struct socket *sock,
 			v.val = sk->sk_state == TCP_LISTEN;
 			break;
 
+		case SO_PASSSEC:
+			v.val = test_bit(SOCK_PASSSEC, &sock->flags) ? 1 : 0;
+			break;
+
 		case SO_PEERSEC:
 			return security_socket_getpeersec_stream(sock, optval, optlen, len);
 
diff -purN -X dontdiff linux-2.6.p/net/unix/af_unix.c linux-2.6.w/net/unix/af_unix.c
--- linux-2.6.p/net/unix/af_unix.c	2006-06-21 00:02:30.000000000 -0400
+++ linux-2.6.w/net/unix/af_unix.c	2006-06-27 02:08:49.000000000 -0400
@@ -1251,6 +1251,7 @@ static int unix_dgram_sendmsg(struct kio
 	struct sk_buff *skb;
 	long timeo;
 	struct scm_cookie tmp_scm;
+	int seclen = 0;
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1290,6 +1291,9 @@ static int unix_dgram_sendmsg(struct kio
 	memcpy(UNIXCREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
 	if (siocb->scm->fp)
 		unix_attach_fds(siocb->scm, skb);
+	err = security_socket_getpeersec_dgram(skb, UNIXSEC(skb), &seclen);
+	if (err)
+		*(UNIXSEC(skb)) = NULL;
 
 	skb->h.raw = skb->data;
 	err = memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len);
@@ -1570,6 +1574,7 @@ static int unix_dgram_recvmsg(struct kio
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
 	}
 	siocb->scm->creds = *UNIXCREDS(skb);
+	siocb->scm->secdata = *UNIXSEC(skb);
 
 	if (!(flags & MSG_PEEK))
 	{
diff -purN -X dontdiff linux-2.6.p/security/selinux/exports.c linux-2.6.w/security/selinux/exports.c
--- linux-2.6.p/security/selinux/exports.c	2006-06-21 00:02:31.000000000 -0400
+++ linux-2.6.w/security/selinux/exports.c	2006-06-27 02:19:16.000000000 -0400
@@ -17,6 +17,7 @@
 #include <linux/selinux.h>
 #include <linux/fs.h>
 #include <linux/ipc.h>
+#include <net/sock.h>
 
 #include "security.h"
 #include "objsec.h"
@@ -72,6 +73,16 @@ void selinux_get_task_sid(struct task_st
 	*sid = 0;
 }
 
+void selinux_get_sock_sid(struct socket *sock, u32 *sid)
+{
+	if (selinux_enabled) {
+		const struct inode *inode = SOCK_INODE(sock);
+		selinux_get_inode_sid(inode, sid);
+		return;
+	}
+	*sid = 0;
+}
+
 int selinux_string_to_sid(char *str, u32 *sid)
 {
 	if (selinux_enabled)
diff -purN -X dontdiff linux-2.6.p/security/selinux/hooks.c linux-2.6.w/security/selinux/hooks.c
--- linux-2.6.p/security/selinux/hooks.c	2006-06-26 14:47:31.000000000 -0400
+++ linux-2.6.w/security/selinux/hooks.c	2006-06-27 02:08:49.000000000 -0400
@@ -69,6 +69,7 @@
 #include <linux/sysctl.h>
 #include <linux/audit.h>
 #include <linux/string.h>
+#include <linux/selinux.h>
 
 #include "avc.h"
 #include "objsec.h"
@@ -3418,7 +3419,12 @@ out:	
 static int selinux_socket_getpeersec_dgram(struct sk_buff *skb, char **secdata, u32 *seclen)
 {
 	int err = 0;
-	u32 peer_sid = selinux_socket_getpeer_dgram(skb);
+	u32 peer_sid;
+
+	if (skb->sk->sk_family == PF_UNIX)
+		selinux_get_sock_sid(skb->sk->sk_socket, &peer_sid);
+	else
+		peer_sid = selinux_socket_getpeer_dgram(skb);
 
 	if (peer_sid == SECSID_NULL)
 		return -EINVAL;
