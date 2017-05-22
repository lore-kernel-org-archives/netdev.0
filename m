From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Sun, 21 May 2017 23:14:10 -0400 (EDT)
Message-ID: <20170521.231410.1999783448679718181.davem@davemloft.net>
References: <20170522111605.14f93676@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, mlichvar@redhat.com,
        willemb@google.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48126 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756946AbdEVDOY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 23:14:24 -0400
In-Reply-To: <20170522111605.14f93676@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 22 May 2017 11:16:05 +1000

> After merging the net-next tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
> 
> net/socket.c: In function 'put_ts_pktinfo':
> net/socket.c:695:28: error: 'SCM_TIMESTAMPING_PKTINFO' undeclared (first use in this function)
>   put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPING_PKTINFO,
>                             ^
> Caused by commit
> 
>   aad9c8c470f2 ("net: add new control message for incoming HW-timestamped packets")
> 
> This probably broke every architecture that has its own
> arch/<arch>/include/uapi/asm/socket.h that does not include
> include/uapi/asm-generic/socket.h :-(
> 
> I have used the net-next tree from next-20170519 for today.

I've just pushed the following, thanks for the report:

====================
net: Define SCM_TIMESTAMPING_PKTINFO on all architectures.

A definition was only provided for asm-generic/socket.h
using platforms, define it for the others as well

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/alpha/include/uapi/asm/socket.h   | 2 ++
 arch/frv/include/uapi/asm/socket.h     | 2 ++
 arch/ia64/include/uapi/asm/socket.h    | 2 ++
 arch/m32r/include/uapi/asm/socket.h    | 2 ++
 arch/mips/include/uapi/asm/socket.h    | 2 ++
 arch/mn10300/include/uapi/asm/socket.h | 2 ++
 arch/parisc/include/uapi/asm/socket.h  | 2 ++
 arch/powerpc/include/uapi/asm/socket.h | 2 ++
 arch/s390/include/uapi/asm/socket.h    | 2 ++
 arch/sparc/include/uapi/asm/socket.h   | 2 ++
 arch/xtensa/include/uapi/asm/socket.h  | 2 ++
 11 files changed, 22 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 148d7a3..0926de6 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -105,4 +105,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 1ccf456..e491ff0 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -98,5 +98,7 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 2c3f4b4..8693724 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -107,4 +107,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index ae6548d..5d97890 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -98,4 +98,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 3418ec9..365ff51 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -116,4 +116,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 4526e92..d013c0d 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -98,4 +98,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 5147018..784b871 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -97,4 +97,6 @@
 
 #define SO_COOKIE		0x4032
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index 58e2ec0..bc4ca72 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -105,4 +105,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index e8e5ecf..fb9769d 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -104,4 +104,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 3f4ad19..5d67330 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -94,6 +94,8 @@
 
 #define SO_COOKIE		0x003b
 
+#define SCM_TIMESTAMPING_PKTINFO	0x003c
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 1eb6d2f..982c253 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -109,4 +109,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif	/* _XTENSA_SOCKET_H */
-- 
2.7.4
