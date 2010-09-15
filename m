From: David Miller <davem@davemloft.net>
Subject: Re: SPARC32 SMP 2.6.36-rc3 build error
Date: Tue, 14 Sep 2010 21:42:35 -0700 (PDT)
Message-ID: <20100914.214235.183040334.davem@davemloft.net>
References: <4C8F78F3.7020408@gaisler.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org
To: daniel@gaisler.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <4C8F78F3.7020408@gaisler.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Hellstrom <daniel@gaisler.com>
Date: Tue, 14 Sep 2010 15:30:27 +0200

> I have problems linking Linux SPARC32 when SMP is enabled:
> 
>  LD      vmlinux
>  SYSMAP  System.map
>  SYSMAP  .tmp_System.map
>  BTFIX   arch/sparc/boot/btfix.S
>  AS      arch/sparc/boot/btfix.o
>  LD      arch/sparc/boot/image
> net/built-in.o: In function `net_rps_action_and_irq_enable':
> /home/daniel/linux/linux/linux-2.6/net/core/dev.c:3337: undefined
> reference to `__smp_call_function_single'
> make[1]: *** [arch/sparc/boot/image] Error 1
> make: *** [zImage] Error 2

It's a missing dependency in the networking code, I'll fix this
in the net-2.6 tree as follows:

--------------------
net: RPS needs to depend upon USE_GENERIC_SMP_HELPERS

You cannot invoke __smp_call_function_single() unless the
architecture sets this symbol.

Reported-by: Daniel Hellstrom <daniel@gaisler.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index e330594..e926884 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -217,7 +217,7 @@ source "net/dns_resolver/Kconfig"
 
 config RPS
 	boolean
-	depends on SMP && SYSFS
+	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
 	default y
 
 menu "Network testing"
-- 
1.7.2.2

