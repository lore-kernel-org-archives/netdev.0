From: Palmer Dabbelt <palmer-96lFi9zoCfxBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 02/13] Always expose __SYSCALL(... fork ...)
Date: Wed,  9 Sep 2015 14:08:11 -0700
Message-ID: <1441832902-28993-3-git-send-email-palmer@dabbelt.com>
References: <2644177.lVCYzIBfPW@wuerfel>
 <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
Cc: 3chas3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org
Cc: mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org
Cc: jikos-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org
Cc: tomi.valkeinen-l0cyMroinI0@public.gmane.org
Cc: x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: Palmer Dabbelt <palmer-96lFi9zoCfxBDgjK7y7TUQ@public.gmane.org>
In-Reply-To: <1441832902-28993-1-git-send-email-palmer-96lFi9zoCfxBDgjK7y7TUQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I think this change actually doesn't do anything: __NR_fork was still
being defined either way, and on my machine fork() in <unistd.h> comes
from libc.

That said, I don't think there's any way to determine this
automatically, so this at least quiets the checker.

Signed-off-by: Palmer Dabbelt <palmer-96lFi9zoCfxBDgjK7y7TUQ@public.gmane.org>
Reviewed-by: Andrew Waterman <waterman-aFE07iDfcCIb0cFwG/AQJIdd74u8MsAO@public.gmane.org>
Reviewed-by: Albert Ou <aou-aFE07iDfcCIb0cFwG/AQJIdd74u8MsAO@public.gmane.org>
---
 include/uapi/asm-generic/unistd.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index e016bd9b1a04..e027ef7aa01f 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -865,11 +865,11 @@ __SYSCALL(__NR_uselib, sys_uselib)
 __SYSCALL(__NR__sysctl, sys_sysctl)
 
 #define __NR_fork 1079
-#ifdef CONFIG_MMU
+#if !defined(__KERNEL__) || defined(CONFIG_MMU)
 __SYSCALL(__NR_fork, sys_fork)
 #else
 __SYSCALL(__NR_fork, sys_ni_syscall)
-#endif /* CONFIG_MMU */
+#endif /* !__KERNEL__ || CONFIG_MMU */
 
 #undef __NR_syscalls
 #define __NR_syscalls (__NR_fork+1)
-- 
2.4.6
