From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH resend 1/4] uapi glibc compat: add libc compat code when not build for kernel
Date: Wed, 12 Apr 2017 22:31:00 +0200
Message-ID: <20170412203103.6057-2-hauke@hauke-m.de>
References: <20170412203103.6057-1-hauke@hauke-m.de>
Cc: linux-kernel@vger.kernel.org, jarod@redhat.com, jogo@openwrt.org,
        david.heidelberger@ixit.cz, maillist-linux@barfooze.de,
        mikko.rapeli@iki.fi, dwmw2@infradead.org,
        Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:43927 "EHLO mail.hauke-m.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754675AbdDLUb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 16:31:26 -0400
In-Reply-To: <20170412203103.6057-1-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of checking if this header file is used in the glibc, check if
iti is not used in kernel context, this way it will also work with
other libc implementations like musl.

Acked-by: Mikko Rapeli <mikko.rapeli@iki.fi>
Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 include/uapi/linux/libc-compat.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
index 44b8a6bd5fe1..7c1fead03c50 100644
--- a/include/uapi/linux/libc-compat.h
+++ b/include/uapi/linux/libc-compat.h
@@ -48,8 +48,8 @@
 #ifndef _UAPI_LIBC_COMPAT_H
 #define _UAPI_LIBC_COMPAT_H
 
-/* We have included glibc headers... */
-#if defined(__GLIBC__)
+/* We have included libc headers... */
+#if !defined(__KERNEL__)
 
 /* Coordinate with glibc net/if.h header. */
 #if defined(_NET_IF_H) && defined(__USE_MISC)
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
