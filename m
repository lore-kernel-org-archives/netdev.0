From: Palmer Dabbelt <palmer@dabbelt.com>
Subject: [PATCH 01/13] Remove #ifdef CONFIG_64BIT from all asm-generic/fcntl.h
Date: Wed,  9 Sep 2015 14:08:10 -0700
Message-ID: <1441832902-28993-2-git-send-email-palmer@dabbelt.com>
References: <2644177.lVCYzIBfPW@wuerfel>
 <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
Cc: 3chas3@gmail.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Cc: hpa@zytor.com
Cc: mingo@redhat.com
Cc: plagnioj@jcrosoft.com
Cc: jikos@kernel.org
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-atm-general@lists.sourceforge.net
Cc: linux-fbdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: tglx@linutronix.de
Cc: tomi.valkeinen@ti.com
Cc: x86@kernel.org
Cc: Palmer Dabbelt <palmer@dabbelt.com>
In-Reply-To: <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When working on the RISC-V port I noticed that F_SETLK64 was being
defined on our 64-bit platform, despite our port being so new that
we've only ever had the 64-bit file ops.  Since there's not compat
layer for these, this causes fcntl to bail out.

It turns out that one of the ways in with F_SETLK64 was being defined
(there's some more in glibc, but that's a whole different story... :))
is the result of CONFIG_64BIT showing up in this user-visible header.
<asm-generic/bitsperlong.h> confirms this isn't sane, so I replaced it
with a __BITS_PER_LONG check.

Signed-off-by: Palmer Dabbelt <palmer@dabbelt.com>
Reviewed-by: Andrew Waterman <waterman@eecs.berkeley.edu>
Reviewed-by: Albert Ou <aou@eecs.berkeley.edu>
---
 include/uapi/asm-generic/fcntl.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
index e063effe0cc1..14a5c8237d84 100644
--- a/include/uapi/asm-generic/fcntl.h
+++ b/include/uapi/asm-generic/fcntl.h
@@ -1,6 +1,7 @@
 #ifndef _ASM_GENERIC_FCNTL_H
 #define _ASM_GENERIC_FCNTL_H
 
+#include <asm/bitsperlong.h>
 #include <linux/types.h>
 
 /*
@@ -115,7 +116,7 @@
 #define F_GETSIG	11	/* for sockets. */
 #endif
 
-#ifndef CONFIG_64BIT
+#if (__BITS_PER_LONG == 32)
 #ifndef F_GETLK64
 #define F_GETLK64	12	/*  using 'struct flock64' */
 #define F_SETLK64	13
-- 
2.4.6
