From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: ARM network performance and dma_mask (was: [BUG,REGRESSION?]
 3.11.6+,3.12: GbE iface rate drops to few KB/s)
Date: Thu, 21 Nov 2013 20:04:33 +0100
Message-ID: <20131121200433.4cb97d9e@skate>
References: <87li0kkhzx.fsf@natisbad.org>
	<1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119174323.GH913@1wt.eu>
	<1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119184121.GN913@1wt.eu>
	<874n780wzc.fsf@natisbad.org>
	<20131120191145.GP8581@1wt.eu>
	<87txf692zx.fsf@natisbad.org>
	<20131120215435.GT8581@1wt.eu>
	<20131121004430.GX8581@1wt.eu>
	<20131121183834.GB18513@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <rob.herring@calxeda.com>,
	Arnaud Ebalard <arno@natisbad.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org, edumazet@google.com,
	Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:60457 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755271Ab3KUTEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 14:04:40 -0500
In-Reply-To: <20131121183834.GB18513@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Willy Tarreau,

On Thu, 21 Nov 2013 19:38:34 +0100, Willy Tarreau wrote:

> While we were diagnosing a network performance regression that we finally
> found and fixed, it appeared during a test that Linus' tree shows a much
> higher performance on Armada 370 (armv7) than its predecessors. I can
> saturate the two Gig links of my Mirabox each with a single TCP flow and
> keep up to 25% of idle CPU in the optimal case. In 3.12.1 or 3.10.20, I
> can achieve around 1.3 Gbps when the two ports are used in parallel.

Interesting finding and analysis, once again!

> I'm not at ease with these things so I'd like to ask your opinion here, is
> this supposed to be an improvement or a fix ? Is this something we should
> backport into stable versions, or is there something to fix in the armada
> platform so that it works just as if the patch was applied ?

I guess the driver should have been setting its dma_mask to 0xffffffff,
since the platform is capable of doing DMA on the first 32 bits of the
physical address space, probably something like calling
pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) or something like that. I know
Russell has recently added some helpers to prevent stupid people (like
me) from doing mistakes when setting the DMA masks. Certainly worth
having a look.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
