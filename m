From: Palmer Dabbelt <palmer@dabbelt.com>
Subject: [PATCH 08/13] Hide MAX_SHARED_LIBS behind #ifdef __KERNEL__
Date: Wed,  9 Sep 2015 14:08:17 -0700
Message-ID: <1441832902-28993-9-git-send-email-palmer@dabbelt.com>
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

I'm not sure what this is, but it doesn't feel like something that
should be exposed to userspace here.  I'm assuming this file was
exposed for the structure in it, which doesn't depend on
MAX_SHARED_LIBS.

Signed-off-by: Palmer Dabbelt <palmer@dabbelt.com>
Reviewed-by: Andrew Waterman <waterman@eecs.berkeley.edu>
Reviewed-by: Albert Ou <aou@eecs.berkeley.edu>
---
 include/uapi/linux/flat.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/flat.h b/include/uapi/linux/flat.h
index 88cd6baba8f3..4ed679f3591e 100644
--- a/include/uapi/linux/flat.h
+++ b/include/uapi/linux/flat.h
@@ -13,11 +13,13 @@
 
 #define	FLAT_VERSION			0x00000004L
 
+#ifdef __KERNEL__
 #ifdef CONFIG_BINFMT_SHARED_FLAT
 #define	MAX_SHARED_LIBS			(4)
 #else
 #define	MAX_SHARED_LIBS			(1)
 #endif
+#endif /*__KERNEL__*/
 
 /*
  * To make everything easier to port and manage cross platform
-- 
2.4.6
