From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] net/core/sysctl_net_core.c: fix PROC_FS=n compile
Date: Sat, 20 Aug 2005 21:03:09 +0200
Message-ID: <20050820190309.GB3615@stusta.de>
References: <20050819043331.7bc1f9a9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932786AbVHTTDh@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20050819043331.7bc1f9a9.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 19, 2005 at 04:33:31AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.13-rc5-mm1:
>...
>  git-net.patch
>...
>  Subsystem trees
>...

This breaks the compilation with CONFIG_PROC_FS=n:

<--  snip  -->

...
  CC      net/core/sysctl_net_core.o
net/core/sysctl_net_core.c:50: error: 'sysctl_wmem_default' undeclared here (not in a function)
net/core/sysctl_net_core.c:58: error: 'sysctl_rmem_default' undeclared here (not in a function)
make[2]: *** [net/core/sysctl_net_core.o] Error 1

<--  snip  -->


The fix is simple.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.13-rc6-mm1-full/include/net/sock.h.old	2005-08-20 15:39:23.000000000 +0200
+++ linux-2.6.13-rc6-mm1-full/include/net/sock.h	2005-08-20 15:39:39.000000000 +0200
@@ -1372,9 +1372,7 @@
 extern int sysctl_optmem_max;
 #endif
 
-#ifdef CONFIG_PROC_FS
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
-#endif
 
 #endif	/* _SOCK_H */
