From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the kspp tree with the net-next tree
Date: Wed, 8 Feb 2017 12:30:05 +1100
Message-ID: <20170208123005.1ffc070f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Mao Wenan <maowenan@huawei.com>,
        Laura Abbott <labbott@redhat.com>
To: Kees Cook <keescook@google.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kees,

Today's linux-next merge of the kspp tree got a conflict in:

  arch/Kconfig

between commit:

  1a8b6d76dc5b ("net:add one common config ARCH_WANT_RELAX_ORDER to support relax ordering")

from the net-next tree and commits:

  ad21fc4faa2a ("arch: Move CONFIG_DEBUG_RODATA and CONFIG_SET_MODULE_RONX to be common")
  0f5bf6d0afe4 ("arch: Rename CONFIG_DEBUG_RODATA and CONFIG_DEBUG_MODULE_RONX")

from the kspp tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc arch/Kconfig
index bd04eace455c,7425fde9c723..000000000000
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@@ -781,7 -843,38 +843,41 @@@ config VMAP_STAC
  	  the stack to map directly to the KASAN shadow map using a formula
  	  that is incorrect if the stack is in vmalloc space.
  
 +config ARCH_WANT_RELAX_ORDER
 +	bool
 +
+ config ARCH_OPTIONAL_KERNEL_RWX
+ 	def_bool n
+ 
+ config ARCH_OPTIONAL_KERNEL_RWX_DEFAULT
+ 	def_bool n
+ 
+ config ARCH_HAS_STRICT_KERNEL_RWX
+ 	def_bool n
+ 
+ config STRICT_KERNEL_RWX
+ 	bool "Make kernel text and rodata read-only" if ARCH_OPTIONAL_KERNEL_RWX
+ 	depends on ARCH_HAS_STRICT_KERNEL_RWX
+ 	default !ARCH_OPTIONAL_KERNEL_RWX || ARCH_OPTIONAL_KERNEL_RWX_DEFAULT
+ 	help
+ 	  If this is set, kernel text and rodata memory will be made read-only,
+ 	  and non-text memory will be made non-executable. This provides
+ 	  protection against certain security exploits (e.g. executing the heap
+ 	  or modifying text)
+ 
+ 	  These features are considered standard security practice these days.
+ 	  You should say Y here in almost all cases.
+ 
+ config ARCH_HAS_STRICT_MODULE_RWX
+ 	def_bool n
+ 
+ config STRICT_MODULE_RWX
+ 	bool "Set loadable kernel module data as NX and text as RO" if ARCH_OPTIONAL_KERNEL_RWX
+ 	depends on ARCH_HAS_STRICT_MODULE_RWX && MODULES
+ 	default !ARCH_OPTIONAL_KERNEL_RWX || ARCH_OPTIONAL_KERNEL_RWX_DEFAULT
+ 	help
+ 	  If this is set, module text and rodata memory will be made read-only,
+ 	  and non-text memory will be made non-executable. This provides
+ 	  protection against certain security exploits (e.g. writing to text)
+ 
  source "kernel/gcov/Kconfig"
