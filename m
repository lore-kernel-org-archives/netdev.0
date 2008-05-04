From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: atl1 64-bit => 32-bit DMA borkage (reproducible, bisected)
Date: Mon, 5 May 2008 01:15:07 +0400
Message-ID: <20080504211507.GC1040@martell.zuzino.mipt.ru>
References: <20080419111719.GA6724@martell.zuzino.mipt.ru> <20080419144535.GA4814@martell.zuzino.mipt.ru> <20080419215444.2d4623f5@osprey.hogchain.net> <20080420111453.GA4902@martell.zuzino.mipt.ru> <20080420060607.2b1be48b@osprey.hogchain.net> <20080420122631.GA4761@martell.zuzino.mipt.ru> <20080420133704.63f5cc10@osprey.hogchain.net> <20080420205500.GA4762@martell.zuzino.mipt.ru> <20080421210821.28053a92@osprey.hogchain.net> <20080425195743.2bfe66ee@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	Chris Snook <csnook@redhat.com>, Jeff Garzik <jeff@garzik.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:56430 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754580AbYEDUTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 16:19:55 -0400
Received: by nf-out-0910.google.com with SMTP id d3so981496nfc.21
        for <netdev@vger.kernel.org>; Sun, 04 May 2008 13:19:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080425195743.2bfe66ee@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looking at how other netdevice drivers:

8139too and others checks netif_running() in interrupt handler.

r8169 has scary "50k$" question comment re irqs disabled after
interacting with hardware.

But the r8169 case should be fixed by atlx_irq_disable()?

Writes to REG_IMR, REG_ISR are commented in atl1_reset_hw(), why?
(I'll test that soon)

Do we have a theory why changing from 64-bit DMA mask to 32-bit mask
resurrects the bug? NIC here never showed any sort of corruption
described in commit which banned 64-bit DMA.

