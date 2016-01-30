From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] net: moxart: use correct accessors for DMA memory
Date: Fri, 29 Jan 2016 19:40:21 -0800 (PST)
Message-ID: <20160129.194021.1464359327401868408.davem@davemloft.net>
References: <2689110.SEuesVebGN@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, linux-kernel@vger.kernel.org,
	David.Laight@aculab.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2689110.SEuesVebGN@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 28 Jan 2016 17:54:33 +0100

> The moxart ethernet driver confuses coherent DMA buffers with
> MMIO registers.
> 
> moxart_ether.c: In function 'moxart_mac_setup_desc_ring':
> moxart_ether.c:146:428: error: passing argument 1 of '__fswab32' makes integer from pointer without a cast [-Werror=int-conversion]
> moxart_ether.c:74:39: warning: incorrect type in argument 3 (different address spaces)
> moxart_ether.c:74:39:    expected void *cpu_addr
> moxart_ether.c:74:39:    got void [noderef] <asn:2>*tx_desc_base
> 
> This leaves the basic logic alone and uses normal pointers for
> the virtual address of the descriptor. As we cannot use readl/writel
> to access them, we also introduce our own moxart_desc_read
> moxart_desc_write helpers that perform the same endianess swap
> as the original code, but without the address space conversion.
> 
> The barriers are made explicit here where needed: Even in the worst-case
> scenario, we just have to use a rmb() after checking ownership so
> we don't read any input data before we are sure it is value, and we
> use wmb() before transferring ownership back to the device.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
