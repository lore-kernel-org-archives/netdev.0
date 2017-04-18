From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v2 1/3] uapi glibc compat: add libc compat code when not build for kernel
Date: Tue, 18 Apr 2017 23:00:34 +0200
Message-ID: <20170418210036.26039-2-hauke@hauke-m.de>
References: <20170418210036.26039-1-hauke@hauke-m.de>
Cc: linux-kernel@vger.kernel.org, jarod@redhat.com, jogo@openwrt.org,
        david.heidelberger@ixit.cz, maillist-linux@barfooze.de,
        mikko.rapeli@iki.fi, dwmw2@infradead.org,
        Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170418210036.26039-1-hauke@hauke-m.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of checking if this header file is used in the glibc, check if
it is not used in kernel context, this way it will also work with other
libc implementations like musl.

The __USE_MISC symbol is glibc specific and not available in musl libc.
Only do this check when glibc is used.

This is based on an older patch from David Heidelberger
<david.heidelberger@ixit.cz>

Acked-by: Mikko Rapeli <mikko.rapeli@iki.fi>
Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 include/uapi/linux/libc-compat.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
index 44b8a6bd5fe1..43a81136ea6e 100644
--- a/include/uapi/linux/libc-compat.h
+++ b/include/uapi/linux/libc-compat.h
@@ -48,11 +48,11 @@
 #ifndef _UAPI_LIBC_COMPAT_H
 #define _UAPI_LIBC_COMPAT_H
 
-/* We have included glibc headers... */
-#if defined(__GLIBC__)
+/* We have included libc headers... */
+#if !defined(__KERNEL__)
 
-/* Coordinate with glibc net/if.h header. */
-#if defined(_NET_IF_H) && defined(__USE_MISC)
+/* Coordinate with libc net/if.h header. */
+#if defined(_NET_IF_H) && (!defined(__GLIBC__) || defined(__USE_MISC))
 
 /* GLIBC headers included first so don't define anything
  * that would already be defined. */
@@ -168,7 +168,7 @@
 /* If we did not see any headers from any supported C libraries,
  * or we are being included in the kernel, then define everything
  * that we need. */
-#else /* !defined(__GLIBC__) */
+#else /* defined(__KERNEL__) */
 
 /* Definitions for if.h */
 #define __UAPI_DEF_IF_IFCONF 1
@@ -208,6 +208,6 @@
 /* Definitions for xattr.h */
 #define __UAPI_DEF_XATTR		1
 
-#endif /* __GLIBC__ */
+#endif /* __KERNEL__ */
 
 #endif /* _UAPI_LIBC_COMPAT_H */
-- 
2.11.0
