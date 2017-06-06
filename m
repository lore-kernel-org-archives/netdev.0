From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: Re: [PATCH] ravb: Fix use-after-free on `ifconfig eth0 down`
Date: Wed, 7 Jun 2017 01:27:34 +0200
Message-ID: <20170606232734.GA8581@vmlxhi-014.adit-jv.com>
References: <20170605220810.3933-1-erosca@de.adit-jv.com>
 <eaf9aa22-9087-977b-b048-3d1906176d1a@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <horms+renesas@verge.net.au>,
        <kazuya.mizuguchi.ks@renesas.com>, <netdev@vger.kernel.org>,
        <linux-renesas-soc@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <eaf9aa22-9087-977b-b048-3d1906176d1a@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 06, 2017 at 12:35:30PM +0300, Sergei Shtylyov wrote:
> Hello!
> 
> On 6/6/2017 1:08 AM, Eugeniu Rosca wrote:
> 
> >Commit a47b70ea86bd ("ravb: unmap descriptors when freeing rings") has
> >introduced the issue seen in [1] reproduced on H3ULCB board.
> >
> >Fix this by relocating the RX skb ringbuffer free operation, so that
> >swiotlb page unmapping can be done first. Freeing of aligned TX buffers
> >is not relevant to the issue seen in [1]. Still, reposition TX free
> >calls as well, to have all kfree() operations performed consistently
> >_after_ dma_unmap_*()/dma_free_*().
> 
>    Perhaps it's a material of a separate cleanup patch?

Many thanks for feedback. For the moment, with a number of sanitizers
and debugging options enabled (UBSAN, KASAN, KMEMLEAK, DMA_API_DEBUG), I
couldn't find any other obvious ravb driver failures in basic usecases
(didn't stress-test it though).

Regarding the reordering of kfree vs dma_* API calls, which might be
needed in other parts of the driver, this possibly will be highlighted
by special usecases like repetitive suspend/resume or the like. I will
happily share any other fixes, if such are developed on our side.

Best regards,
Eugeniu.
