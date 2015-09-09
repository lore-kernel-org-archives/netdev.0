From: Palmer Dabbelt <palmer@dabbelt.com>
Subject: [PATCH 04/13] Always expose MAP_UNINITIALIZED to userspace
Date: Wed,  9 Sep 2015 14:08:13 -0700
Message-ID: <1441832902-28993-5-git-send-email-palmer@dabbelt.com>
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

This used to be hidden behind CONFIG_MMAP_ALLOW_UNINITIALIZED, so
userspace wouldn't actually ever see it.  While I could have kept
hiding it, the man pages seem to indicate that MAP_UNINITIALIZED
should be visible:

  mmap(2)
  MAP_UNINITIALIZED (since Linux 2.6.33)
    Don't clear anonymous pages.  This flag is intended to improve
    performance on embedded devices.  This flag is honored only if the
    kernel was configured with the CONFIG_MMAP_ALLOW_UNINITIALIZED
    option.  Because of the security implications, that option is
    normally enabled only on embedded devices (i.e., devices where one
    has complete control of the contents of user memory).

and since the only time it shows up in my /usr/include is in this
header I believe this should have been visible to userspace (as
non-zero, which wouldn't do anything when or'd into the flags) all
along.

Signed-off-by: Palmer Dabbelt <palmer@dabbelt.com>
Reviewed-by: Andrew Waterman <waterman@eecs.berkeley.edu>
Reviewed-by: Albert Ou <aou@eecs.berkeley.edu>
---
 include/uapi/asm-generic/mman-common.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index ddc3b36f1046..e58d1911ecc6 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -19,7 +19,7 @@
 #define MAP_TYPE	0x0f		/* Mask for type of mapping */
 #define MAP_FIXED	0x10		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x20		/* don't use a file */
-#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
+#if !defined(__KERNEL__) || defined(CONFIG_MMAP_ALLOW_UNINITIALIZED)
 # define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be uninitialized */
 #else
 # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
-- 
2.4.6
