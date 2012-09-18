From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 24/24] net: seeq: use __iomem pointers for MMIO
Date: Tue, 18 Sep 2012 08:14:38 +0000
Message-ID: <201209180814.38975.arnd@arndb.de>
References: <1347658492-11608-1-git-send-email-arnd@arndb.de> <20120914235607.GF12245@n2100.arm.linux.org.uk> <20120915.000059.636218745264773259.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, will.deacon@arm.com, nico@linaro.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120915.000059.636218745264773259.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 15 September 2012, David Miller wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Sat, 15 Sep 2012 00:56:07 +0100
> 
> > On Fri, Sep 14, 2012 at 11:34:52PM +0200, Arnd Bergmann wrote:
> >> ARM is moving to stricter checks on readl/write functions,
> >> so we need to use the correct types everywhere.
> > 
> > Same comment as for eesox.  const void __iomem * is not a problem on
> > x86, so it should not be a problem on ARM.
> 
> Agreed.

As discussed in the thread for the same patch on the scsi eesox driver,
x86 allows reads on const __iomem pointers, but not writes, and the patch
to asm/io.h that Russell has queued up changes ARM to do the same.

My patch on seeq/ether3.c is still needed to avoid this warning in
linux-next:

drivers/net/ethernet/seeq/ether3.c: In function 'ether3_outb':
drivers/net/ethernet/seeq/ether3.c:104:2: error: passing argument 2 of '__raw_writeb' discards 'const' qualifier from pointer target type
arch/arm/include/asm/io.h:81:91: note: expected 'volatile void *' but argument is of type 'const void *'

	Arnd
