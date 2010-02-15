From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH -mm] ssb: open-code dma_alloc_coherent
Date: Mon, 15 Feb 2010 12:03:41 +0100
Message-ID: <201002151203.42805.mb@bu3sch.de>
References: <20100215142111R.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, stefano.brivio@polimi.it,
	Larry.Finger@lwfinger.net, akpm@linux-foundation.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100215142111R.fujita.tomonori@lab.ntt.co.jp>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 15 February 2010 06:21:58 FUJITA Tomonori wrote:
> This patch is against -mm since it depends on the DMA API changes in

I appreciate your efforts to remove bus-specific APIs.
However, always keep in mind that a SSB bus might be running on a system
where there's no PCI bus at all.
In the past we used the generic dma_... API for DMA operations on all
SSB devices. This worked 99.9% of the time. _But_ it broke in really obscure
cases where the architecture implementations _slightly_ differed between
the generic dma and the pci variants.

So, I'm all for it. But simply keep in mind that this has to run on lots of
architectures (i386, x86_64, ppc, MIPS, probably more) and it has to run on
machines without a PCI bus (where SSB is the main system bus).

-- 
Greetings, Michael.
