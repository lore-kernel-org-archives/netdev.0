From: Steffen Sledz <sledz@dresearch.de>
Subject: [PATCH v2] tcp: ioctl type SIOCOUTQNSD returns amount of data not sent
Date: Fri,  4 Mar 2011 11:20:31 +0100
Message-ID: <1299234031-13937-1-git-send-email-sledz@dresearch.de>
References: <201103041057.53671.arnd@arndb.de>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Mario Schuknecht <m.schuknecht@dresearch.de>,
	Steffen Sledz <sledz@dresearch.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy.DResearch.DE ([87.193.137.100]:33564 "EHLO
	mail.dresearch.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759274Ab1CDKUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 05:20:53 -0500
In-Reply-To: <201103041057.53671.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mario Schuknecht <m.schuknecht@dresearch.de>

In contrast to SIOCOUTQ which returns the amount of data sent
but not yet acknowledged plus data not yet sent this patch only
returns the data not sent.

For various methods of live streaming bitrate control it may
be helpful to know how much data are in the tcp outqueue are
not sent yet.

Signed-off-by: Mario Schuknecht <m.schuknecht@dresearch.de>
Signed-off-by: Steffen Sledz <sledz@dresearch.de>
---
 arch/alpha/include/asm/ioctls.h   |    3 ++-
 arch/mips/include/asm/ioctls.h    |    3 ++-
 arch/parisc/include/asm/ioctls.h  |    3 ++-
 arch/powerpc/include/asm/ioctls.h |    3 ++-
 arch/sh/include/asm/ioctls.h      |    3 ++-
 arch/sparc/include/asm/ioctls.h   |    3 ++-
 arch/xtensa/include/asm/ioctls.h  |    3 ++-
 include/asm-generic/ioctls.h      |    3 ++-
 include/linux/sockios.h           |    1 +
 net/ipv4/tcp.c                    |    9 +++++++++
 10 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/arch/alpha/include/asm/ioctls.h b/arch/alpha/include/asm/ioctls.h
index 80e1cee..5ceb2de 100644
--- a/arch/alpha/include/asm/ioctls.h
+++ b/arch/alpha/include/asm/ioctls.h
@@ -35,12 +35,13 @@
 #define TIOCGWINSZ	_IOR('t', 104, struct winsize)
 #define	TIOCSTART	_IO('t', 110)		/* start output, like ^Q */
 #define	TIOCSTOP	_IO('t', 111)		/* stop output, like ^S */
-#define TIOCOUTQ        _IOR('t', 115, int)     /* output queue size */
+#define TIOCOUTQ        _IOR('t', 115, int)     /* output queue size (not send + not acked) */
 
 #define TIOCGLTC	_IOR('t', 116, struct ltchars)
 #define TIOCSLTC	_IOW('t', 117, struct ltchars)
 #define TIOCSPGRP	_IOW('t', 118, int)
 #define TIOCGPGRP	_IOR('t', 119, int)
+#define TIOCOUTQNSD     _IOR('t', 120, int)     /* output queue size (not send only) */
 
 #define TIOCEXCL	0x540C
 #define TIOCNXCL	0x540D
diff --git a/arch/mips/include/asm/ioctls.h b/arch/mips/include/asm/ioctls.h
index 92403c3..dd8d8c5 100644
--- a/arch/mips/include/asm/ioctls.h
+++ b/arch/mips/include/asm/ioctls.h
@@ -27,7 +27,8 @@
 
 #define TIOCEXCL	0x740d		/* set exclusive use of tty */
 #define TIOCNXCL	0x740e		/* reset exclusive use of tty */
-#define TIOCOUTQ	0x7472		/* output queue size */
+#define TIOCOUTQ	0x7472		/* output queue size (not send + not acked) */
+#define TIOCOUTQNSD	0x7473		/* output queue size (not send only) */
 #define TIOCSTI		0x5472		/* simulate terminal input */
 #define TIOCMGET	0x741d		/* get all modem bits */
 #define TIOCMBIS	0x741b		/* bis modem bits */
diff --git a/arch/parisc/include/asm/ioctls.h b/arch/parisc/include/asm/ioctls.h
index 054ec06..1cf1681 100644
--- a/arch/parisc/include/asm/ioctls.h
+++ b/arch/parisc/include/asm/ioctls.h
@@ -21,7 +21,7 @@
 #define TIOCSCTTY	0x540E
 #define TIOCGPGRP	_IOR('T', 30, int)
 #define TIOCSPGRP	_IOW('T', 29, int)
-#define TIOCOUTQ	0x5411
+#define TIOCOUTQ	0x5411 /* output queue size (not send + not acked) */
 #define TIOCSTI		0x5412
 #define TIOCGWINSZ	0x5413
 #define TIOCSWINSZ	0x5414
@@ -55,6 +55,7 @@
 #define TIOCGDEV	_IOR('T',0x32, int)  /* Get primary device node of /dev/console */
 #define TIOCSIG		_IOW('T',0x36, int)  /* Generate signal on Pty slave */
 #define TIOCVHANGUP	0x5437
+#define TIOCOUTQNSD	0x5438 /* output queue size (not send only) */
 
 #define FIONCLEX	0x5450  /* these numbers need to be adjusted. */
 #define FIOCLEX		0x5451
diff --git a/arch/powerpc/include/asm/ioctls.h b/arch/powerpc/include/asm/ioctls.h
index e9b7887..ae1b21e 100644
--- a/arch/powerpc/include/asm/ioctls.h
+++ b/arch/powerpc/include/asm/ioctls.h
@@ -35,12 +35,13 @@
 #define TIOCGWINSZ	_IOR('t', 104, struct winsize)
 #define	TIOCSTART	_IO('t', 110)		/* start output, like ^Q */
 #define	TIOCSTOP	_IO('t', 111)		/* stop output, like ^S */
-#define TIOCOUTQ        _IOR('t', 115, int)     /* output queue size */
+#define TIOCOUTQ        _IOR('t', 115, int)     /* output queue size (not send + not acked) */
 
 #define TIOCGLTC	_IOR('t', 116, struct ltchars)
 #define TIOCSLTC	_IOW('t', 117, struct ltchars)
 #define TIOCSPGRP	_IOW('t', 118, int)
 #define TIOCGPGRP	_IOR('t', 119, int)
+#define TIOCOUTQNSD     _IOR('t', 120, int)     /* output queue size (not send only) */
 
 #define TIOCEXCL	0x540C
 #define TIOCNXCL	0x540D
diff --git a/arch/sh/include/asm/ioctls.h b/arch/sh/include/asm/ioctls.h
index a6769f3..f0bd75a 100644
--- a/arch/sh/include/asm/ioctls.h
+++ b/arch/sh/include/asm/ioctls.h
@@ -29,7 +29,8 @@
 #define TIOCGWINSZ	0x80087468	/* _IOR('t', 104, struct winsize) */
 #define	TIOCSTART	_IO('t', 110)		/* start output, like ^Q */
 #define	TIOCSTOP	_IO('t', 111)		/* stop output, like ^S */
-#define TIOCOUTQ        _IOR('t', 115, int)     /* output queue size */
+#define TIOCOUTQ        _IOR('t', 115, int)     /* output queue size (not send + not acked) */
+#define TIOCOUTQNSD     _IOR('t', 116, int)     /* output queue size (not send only) */
 
 #define TIOCSPGRP	_IOW('t', 118, int)
 #define TIOCGPGRP	_IOR('t', 119, int)
diff --git a/arch/sparc/include/asm/ioctls.h b/arch/sparc/include/asm/ioctls.h
index 28d0c8b..184acc3 100644
--- a/arch/sparc/include/asm/ioctls.h
+++ b/arch/sparc/include/asm/ioctls.h
@@ -60,7 +60,7 @@
 #define TIOCPKT		_IOW('t', 112, int)
 #define TIOCNOTTY	_IO('t', 113)
 #define TIOCSTI		_IOW('t', 114, char)
-#define TIOCOUTQ	_IOR('t', 115, int)
+#define TIOCOUTQ	_IOR('t', 115, int) /* output queue size (not send + not acked) */
 #define __TIOCGLTC        _IOR('t', 116, struct ltchars) /* SunOS Specific */
 #define __TIOCSLTC        _IOW('t', 117, struct ltchars) /* SunOS Specific */
 /* 118 is the non-posix setpgrp tty ioctl */
@@ -83,6 +83,7 @@
 #define TIOCGPTN	_IOR('t', 134, unsigned int) /* Get Pty Number */
 #define TIOCSPTLCK	_IOW('t', 135, int) /* Lock/unlock PTY */
 #define TIOCSIG		_IOW('t', 136, int) /* Generate signal on Pty slave */
+#define TIOCOUTQNSD	_IOW('t', 137, int) /* output queue size (not send only) */
 
 /* Little f */
 #define FIOCLEX		_IO('f', 1)
diff --git a/arch/xtensa/include/asm/ioctls.h b/arch/xtensa/include/asm/ioctls.h
index fd1d136..5222d8c 100644
--- a/arch/xtensa/include/asm/ioctls.h
+++ b/arch/xtensa/include/asm/ioctls.h
@@ -41,7 +41,8 @@
 #define TIOCGWINSZ	_IOR('t', 104, struct winsize)
 #define	TIOCSTART	_IO('t', 110)		/* start output, like ^Q */
 #define	TIOCSTOP	_IO('t', 111)		/* stop output, like ^S */
-#define TIOCOUTQ        _IOR('t', 115, int)     /* output queue size */
+#define TIOCOUTQ        _IOR('t', 115, int)     /* output queue size (not send + not acked) */
+#define TIOCOUTQNSD     _IOR('t', 116, int)     /* output queue size (not send only) */
 
 #define TIOCSPGRP	_IOW('t', 118, int)
 #define TIOCGPGRP	_IOR('t', 119, int)
diff --git a/include/asm-generic/ioctls.h b/include/asm-generic/ioctls.h
index 199975f..231e492 100644
--- a/include/asm-generic/ioctls.h
+++ b/include/asm-generic/ioctls.h
@@ -32,7 +32,7 @@
 #define TIOCSCTTY	0x540E
 #define TIOCGPGRP	0x540F
 #define TIOCSPGRP	0x5410
-#define TIOCOUTQ	0x5411
+#define TIOCOUTQ	0x5411 /* output queue size (not send + not acked) */
 #define TIOCSTI		0x5412
 #define TIOCGWINSZ	0x5413
 #define TIOCSWINSZ	0x5414
@@ -74,6 +74,7 @@
 #define TCSETXW		0x5435
 #define TIOCSIG		_IOW('T', 0x36, int)  /* pty: generate signal */
 #define TIOCVHANGUP	0x5437
+#define TIOCOUTQNSD	0x5438 /* output queue size (not send only) */
 
 #define FIONCLEX	0x5450
 #define FIOCLEX		0x5451
diff --git a/include/linux/sockios.h b/include/linux/sockios.h
index 241f179..4c5ca47 100644
--- a/include/linux/sockios.h
+++ b/include/linux/sockios.h
@@ -23,6 +23,7 @@
 /* Linux-specific socket ioctls */
 #define SIOCINQ		FIONREAD
 #define SIOCOUTQ	TIOCOUTQ
+#define SIOCOUTQNSD	TIOCOUTQNSD
 
 /* Routing table calls. */
 #define SIOCADDRT	0x890B		/* add routing table entry	*/
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index a17a5a7..b22d450 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -505,6 +505,15 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 		else
 			answ = tp->write_seq - tp->snd_una;
 		break;
+	case SIOCOUTQNSD:
+		if (sk->sk_state == TCP_LISTEN)
+			return -EINVAL;
+
+		if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV))
+			answ = 0;
+		else
+			answ = tp->write_seq - tp->snd_nxt;
+		break;
 	default:
 		return -ENOIOCTLCMD;
 	}
-- 
1.7.1

