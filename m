From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tip tree with the net-next tree
Date: Thu, 17 Nov 2016 14:04:04 +1100
Message-ID: <20161117140404.0f960966@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        Thomas Lendacky <Thomas.Lendacky@amd.com>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the tip tree got a conflict in:

  drivers/net/ethernet/amd/Kconfig

between commits:

  e78332b2285d ("amd-xgbe: Add ECC status support for the device memory")
  abf0a1c2b26a ("amd-xgbe: Add support for SFP+ modules")

from the net-next tree and commit:

  d1cbfd771ce8 ("ptp_clock: Allow for it to be optional")

from the tip tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/amd/Kconfig
index 7ab6efbe4189,713ea7ad22c3..000000000000
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@@ -173,13 -173,11 +173,13 @@@ config SUNLANC
  
  config AMD_XGBE
  	tristate "AMD 10GbE Ethernet driver"
 -	depends on ((OF_NET && OF_ADDRESS) || ACPI) && HAS_IOMEM && HAS_DMA
 -	depends on ARM64 || COMPILE_TEST
 +	depends on ((OF_NET && OF_ADDRESS) || ACPI || PCI) && HAS_IOMEM && HAS_DMA
 +	depends on X86 || ARM64 || COMPILE_TEST
  	select BITREVERSE
  	select CRC32
- 	select PTP_1588_CLOCK
 +	select PHYLIB
 +	select AMD_XGBE_HAVE_ECC if X86
+ 	imply PTP_1588_CLOCK
  	---help---
  	  This driver supports the AMD 10GbE Ethernet device found on an
  	  AMD SoC.
