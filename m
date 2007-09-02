From: Adrian Bunk <bunk@kernel.org>
Subject: [-mm patch] IPV6 must select XFRM
Date: Sun, 2 Sep 2007 13:25:57 +0200
Message-ID: <20070902112557.GK16016@stusta.de>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965155AbXIBL0P@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070831215822.26e1432b.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 09:58:22PM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.23-rc3-mm1:
>...
>  git-net.patch
>...
>  git trees
>...

This patch fixes the following compile error:

<--  snip  -->

...
  LD      .tmp_vmlinux1
net/built-in.o: In function `inet6_csk_xmit':
(.text+0x72b0f): undefined reference to `flow_cache_genid'
net/built-in.o: In function `inet6_csk_xmit':
(.text+0x72be5): undefined reference to `flow_cache_genid'
make[1]: *** [.tmp_vmlinux1] Error 1

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -5,6 +5,7 @@
 #   IPv6 as module will cause a CRASH if you try to unload it
 config IPV6
 	tristate "The IPv6 protocol"
+	select XFRM
 	default m
 	---help---
 	  This is complemental support for the IP version 6.
