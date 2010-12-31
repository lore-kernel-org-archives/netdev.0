From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] starfire: Fix dma_addr_t size test for MIPS
Date: Fri, 31 Dec 2010 12:34:43 -0800 (PST)
Message-ID: <20101231.123443.35039907.davem@davemloft.net>
References: <1293632777.2928.127.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ionut@badula.org, akinobu.mita@gmail.com,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51401
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753492Ab0LaUeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 15:34:12 -0500
In-Reply-To: <1293632777.2928.127.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 29 Dec 2010 14:26:17 +0000

> Commit 56543af "starfire: use BUILD_BUG_ON for netdrv_addr_t" revealed
> that the preprocessor condition used to find the size of dma_addr_t
> yielded the wrong result for some architectures and configurations.
> This was kluged for 64-bit PowerPC in commit 3e502e6 by adding yet
> another case to the condition.  However, 64-bit MIPS configurations
> are not detected reliably either.
> 
> This should be fixed by using CONFIG_ARCH_DMA_ADDR_T_64BIT, but that
> isn't yet defined everywhere it should be.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied to net-2.6, thanks.

> The MIPS conditions are changed to match those Tomonori specified for
> CONFIG_ARCH_DMA_ADDR_T_64BIT.
> 
> Please change the condition to defined(CONFIG_ARCH_DMA_ADDR_T_64BIT) in
> net-next-2.6.  I leave it up to you to decide when to make that change.
> (Simply applying a patch to net-next-2.6 now will result in a later
> merge conflict and breakage for those two architectures.)

The thing to do here is to make this change after the next merge
window takes in Fujita's patch definiting ARCH_DMA_ADDR_T_64BIT from
the -mm set.
