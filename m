From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the kspp tree with the net-next tree
Date: Wed, 22 Feb 2017 10:51:32 +1100
Message-ID: <20170222105132.4abc18e8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        Laura Abbott <labbott@redhat.com>
To: Kees Cook <keescook@google.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kees,

Today's linux-next merge of the kspp tree got a conflict in:

  arch/arm/Kconfig

between commit:

  d2852a224050 ("arch: add ARCH_HAS_SET_MEMORY config")

from the net-next tree and commit:

  ad21fc4faa2a ("arch: Move CONFIG_DEBUG_RODATA and CONFIG_SET_MODULE_RONX to be common")

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

diff --cc arch/arm/Kconfig
index 08d6a701c4fd,8748353ed5e0..000000000000
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@@ -2,10 -2,10 +2,12 @@@ config AR
  	bool
  	default y
  	select ARCH_CLOCKSOURCE_DATA
 +	select ARCH_HAS_DEBUG_VIRTUAL
  	select ARCH_HAS_DEVMEM_IS_ALLOWED
  	select ARCH_HAS_ELF_RANDOMIZE
 +	select ARCH_HAS_SET_MEMORY
+ 	select ARCH_HAS_STRICT_KERNEL_RWX if MMU && !XIP_KERNEL
+ 	select ARCH_HAS_STRICT_MODULE_RWX if MMU
  	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
  	select ARCH_HAVE_CUSTOM_GPIO_H
  	select ARCH_HAS_GCOV_PROFILE_ALL
