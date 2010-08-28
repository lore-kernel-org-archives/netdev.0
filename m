From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] starfire: use BUILD_BUG_ON for netdrv_addr_t
Date: Sat, 28 Aug 2010 15:41:25 -0700 (PDT)
Message-ID: <20100828.154125.246523501.davem@davemloft.net>
References: <1282972125-9968-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ionut@badula.org,
	fujita.tomonori@lab.ntt.co.jp
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56028
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752874Ab0H1WlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 18:41:09 -0400
In-Reply-To: <1282972125-9968-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Sat, 28 Aug 2010 14:08:45 +0900

> Detect size mismatch for netdrv_addr_t at build time rather than
> checking at module load time.
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: Ion Badulescu <ionut@badula.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org

Applied, but I suspect we will see some interesting build failures now
if that ugly and brittle ifdef test which constrols the netdrv_addr_t
define isn't %100 accurate.

Fujita-san, what this driver does is actually pretty reasonable.  It
has two kinds of descriptors, one supports 32-bit addresses and the
other supports 64-bit addresses.  It wants to CPP test which one to
use so that the driver is not burdoned with two duplicated sets of
routines.

Maybe we should provide a DMA_ADDR_T_SIZE or similar macro?  What do
you think?  Anything is better than what it uses now:

/*
 * This SUCKS.
 * We need a much better method to determine if dma_addr_t is 64-bit.
 */
#if (defined(__i386__) && defined(CONFIG_HIGHMEM64G)) || defined(__x86_64__) || defined (__ia64__) || defined(__alpha__) || defined(__mips64__) || (defined(__mips__) && defined(CONFIG_HIGHMEM) && defined(CONFIG_64BIT_PHYS_ADDR))

:-)

