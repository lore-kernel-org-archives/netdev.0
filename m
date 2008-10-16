From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: powerpc allmodconfig
Date: Wed, 15 Oct 2008 23:08:12 -0700
Message-ID: <1224137292.26782.5.camel@dwillia2-linux.ch.intel.com>
References: <20081015213337.a99a9595.akpm@linux-foundation.org>
	 <20081015.220247.262683261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, tiwai@suse.de,
	linux-ext4@vger.kernel.org, netdev@vger.kernel.org,
	linux-ide@vger.kernel.org, bzolnier@gmail.com,
	marek.vasut@gmail.com, dwmw2@infradead.org, mark.fasheh@oracle.com,
	ralf@linux-mips.org, mchehab@infradead.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, brice@myri.com, jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20081015.220247.262683261.davem@davemloft.net>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2008-10-15 at 22:02 -0700, David Miller wrote:
> > drivers/dma/ioat_dca.c: In function 'dca_enabled_in_bios':
> > drivers/dma/ioat_dca.c:81: error: implicit declaration of function 'cpuid_eax'
> > drivers/dma/ioat_dca.c: In function 'system_has_dca_enabled':
> > drivers/dma/ioat_dca.c:91: error: implicit declaration of function 'boot_cpu_has'
> > drivers/dma/ioat_dca.c:91: error: 'X86_FEATURE_DCA' undeclared (first use in this function)
> > drivers/dma/ioat_dca.c:91: error: (Each undeclared identifier is reported only once
> > drivers/dma/ioat_dca.c:91: error: for each function it appears in.)
> > drivers/dma/ioat_dca.c: In function 'ioat_dca_get_tag':
> > drivers/dma/ioat_dca.c:190: error: implicit declaration of function 'cpu_physical_id'
> 
> Known issue.  I tried to ping Jeff Garzik about doing a driver bug fix run in
> order to fix this, but he hasn't shown any signs of life.
> 
> So I'll do it myself later tonight. :-/
> 
The following seems to fix this up...

---snip--->
ixgbe, myri10ge: INTEL_IOATDMA can only be selected when X86=y

From: Dan Williams <dan.j.williams@intel.com>

The INTEL_IOATDMA symbol depends on x86. 'select' ignores this
dependency.

Cc: Brice Goglin <brice@myri.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 drivers/net/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 1d8af33..84983f8 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2410,7 +2410,7 @@ config IXGBE
 	tristate "Intel(R) 10GbE PCI Express adapters support"
 	depends on PCI && INET
 	select INET_LRO
-	select INTEL_IOATDMA
+	select INTEL_IOATDMA if X86
 	---help---
 	  This driver supports Intel(R) 10GbE PCI Express family of
 	  adapters.  For more information on how to identify your adapter, go
@@ -2462,7 +2462,7 @@ config MYRI10GE
 	select FW_LOADER
 	select CRC32
 	select INET_LRO
-	select INTEL_IOATDMA
+	select INTEL_IOATDMA if X86
 	---help---
 	  This driver supports Myricom Myri-10G Dual Protocol interface in
 	  Ethernet mode. If the eeprom on your board is not recent enough,


