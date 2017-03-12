From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 2/4] uapi glibc compat: fix build if libc defines IFF_ECHO
Date: Sun, 12 Mar 2017 23:00:37 +0100
Message-ID: <20170312220039.16885-3-hauke@hauke-m.de>
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

musl 1.1.15 defines IFF_ECHO and the other net_device_flags options.
When a user application includes linux/if.h and net/if.h the compile
will fail.

Activate __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO only when
it is needed. This should also make this work in case glibc will add
these defines.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 include/uapi/linux/libc-compat.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
index 7c1fead03c50..49a8cc3138ae 100644
--- a/include/uapi/linux/libc-compat.h
+++ b/include/uapi/linux/libc-compat.h
@@ -64,9 +64,11 @@
 /* Everything up to IFF_DYNAMIC, matches net/if.h until glibc 2.23 */
 #define __UAPI_DEF_IF_NET_DEVICE_FLAGS 0
 /* For the future if glibc adds IFF_LOWER_UP, IFF_DORMANT and IFF_ECHO */
+#ifndef IFF_ECHO
 #ifndef __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO
 #define __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO 1
 #endif /* __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO */
+#endif /* IFF_ECHO */
 
 #else /* _NET_IF_H */
 
-- 
2.11.0
