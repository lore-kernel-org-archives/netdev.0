From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 3/4] uapi glibc compat: Do not check for __USE_MISC
Date: Sun, 12 Mar 2017 23:00:38 +0100
Message-ID: <20170312220039.16885-4-hauke@hauke-m.de>
References: <20170312220039.16885-1-hauke@hauke-m.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jarod@redhat.com, jogo@openwrt.org, david.heidelberger@ixit.cz,
        maillist-linux@barfooze.de, mikko.rapeli@iki.fi,
        Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170312220039.16885-1-hauke@hauke-m.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

__USE_MISC is glibc specific and not available in musl libc. Only do
this check when glibc is used. This fixes a problem with musl libc.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 include/uapi/linux/libc-compat.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
index 49a8cc3138ae..ce2fa8a4ced6 100644
--- a/include/uapi/linux/libc-compat.h
+++ b/include/uapi/linux/libc-compat.h
@@ -51,8 +51,8 @@
 /* We have included libc headers... */
 #if !defined(__KERNEL__)
 
-/* Coordinate with glibc net/if.h header. */
-#if defined(_NET_IF_H) && defined(__USE_MISC)
+/* Coordinate with libc net/if.h header. */
+#if defined(_NET_IF_H) && (!defined(__GLIBC__) || defined(__USE_MISC))
 
 /* GLIBC headers included first so don't define anything
  * that would already be defined. */
-- 
2.11.0
