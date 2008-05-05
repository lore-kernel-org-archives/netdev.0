From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: atl1 64-bit => 32-bit DMA borkage (reproducible, bisected)
Date: Sun, 4 May 2008 19:31:28 -0500
Message-ID: <20080504193128.1ea61958@osprey.hogchain.net>
References: <20080419111719.GA6724@martell.zuzino.mipt.ru>
	<20080419144535.GA4814@martell.zuzino.mipt.ru>
	<20080419215444.2d4623f5@osprey.hogchain.net>
	<20080420111453.GA4902@martell.zuzino.mipt.ru>
	<20080420060607.2b1be48b@osprey.hogchain.net>
	<20080420122631.GA4761@martell.zuzino.mipt.ru>
	<20080420133704.63f5cc10@osprey.hogchain.net>
	<20080420205500.GA4762@martell.zuzino.mipt.ru>
	<20080421210821.28053a92@osprey.hogchain.net>
	<20080425195743.2bfe66ee@osprey.hogchain.net>
	<20080504211507.GC1040@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	Chris Snook <csnook@redhat.com>, Jeff Garzik <jeff@garzik.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([207.115.11.54]:35679 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750750AbYEEAbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 20:31:33 -0400
In-Reply-To: <20080504211507.GC1040@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 May 2008 01:15:07 +0400
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> Looking at how other netdevice drivers:
> 
> 8139too and others checks netif_running() in interrupt handler.
> 
> r8169 has scary "50k$" question comment re irqs disabled after
> interacting with hardware.
> 
> But the r8169 case should be fixed by atlx_irq_disable()?

Agreed.

> 
> Writes to REG_IMR, REG_ISR are commented in atl1_reset_hw(), why?

Came from the vendor that way.

> (I'll test that soon)
> 
> Do we have a theory why changing from 64-bit DMA mask to 32-bit mask
> resurrects the bug? NIC here never showed any sort of corruption
> described in commit which banned 64-bit DMA.

We had multiple reports of users who encountered repeated memory
corruption when transferring large files while running with a 64-bit DMA
mask.  Chris Snook noticed the upper 32 bits of the descriptor address
register are shared among five other registers, each containing the low
bits for one of five descriptors.  All the descriptors, therefore, have
to live within the same 4GB address space.

I'll keep poking at it as time permits through the week, but I probably
won't be able to devote a whole lot of time to it until next weekend.
