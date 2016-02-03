From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Keystone 2 boards boot failure
Date: Wed, 03 Feb 2016 21:40:51 +0100
Message-ID: <1935541.nO0q7ZEBnd@wuerfel>
References: <56B0DE61.2000704@ti.com> <1888105.8DsfvU3cAo@wuerfel> <56B22B44.9050802@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "Franklin S Cooper Jr." <fcooper@ti.com>, m-karicheri2@ti.com,
	netdev@vger.kernel.org, w-kwok2@ti.com, davem@davemloft.net,
	Santosh Shilimkar <ssantosh@kernel.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:60378 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088AbcBCUlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 15:41:07 -0500
In-Reply-To: <56B22B44.9050802@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 03 February 2016 18:31:00 Grygorii Strashko wrote:
> On 02/03/2016 06:20 PM, Arnd Bergmann wrote:
> > On Wednesday 03 February 2016 16:21:05 Grygorii Strashko wrote:
> >> On 02/03/2016 04:11 PM, Franklin S Cooper Jr. wrote:
> >>> On 02/02/2016 07:19 PM, Franklin S Cooper Jr. wrote:
> >
> > This looks wrong: I was getting the build warnings originally
> > because of 64-bit dma_addr_t, and that should be the only way that
> > this driver can operate, because in some configurations on keystone
> > there is no memory below 4GB, and there is no dma-ranges property
> > in the DT that shifts around the start of the DMA addresses.
> 
> see keystone.dtsi:
> 	soc {
> 		#address-cells = <1>;
> 		#size-cells = <1>;
> 		compatible = "ti,keystone","simple-bus";
> 		interrupt-parent = <&gic>;
> 		ranges = <0x0 0x0 0x0 0xc0000000>;
> 		dma-ranges = <0x80000000 0x8 0x00000000 0x80000000>;
> 		^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You are right, I totally missed it when I looked again. I thought it
was correct but then couldn't find it in the dts.

> config:
> 
> CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
> CONFIG_PHYS_ADDR_T_64BIT=y
> 
> and
> 
> #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT <--- should not be defined for KS2
> typedef u64 dma_addr_t;
> #else
> typedef u32 dma_addr_t;
> #endif
> 
> Above is valid configuration for Keystone 2 with LPAE=y

Ok, but what do you mean with "should not be defined"? It clearly is
defined in any multiplatform configuration that enables another platform
needing 64-bit dma_addr_t.


	Arnd
