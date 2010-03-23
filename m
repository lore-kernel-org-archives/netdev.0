From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: ixgbe: Set IXGBE_RSC_CB(skb)->DMA field to zero after
 unmapping the address
Date: Wed, 24 Mar 2010 10:40:53 +1100
Message-ID: <1269387653.8599.132.camel@pasglop>
References: <201003221759.o2MHxEaj015546@hera.kernel.org>
	 <1269316670.8599.101.camel@pasglop>
	 <7991c5481003231040u3479778dpcb27d9578383afc0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Malli <mchilakala@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7991c5481003231040u3479778dpcb27d9578383afc0@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-03-23 at 10:40 -0700, Malli wrote:
> 
> Yes. I just realized that i can't assign a zero magic "bad" value. It
> is only
> valid in x86/arm/m68k/alpha architecures and not in spark & PowerPC
> arch,
> (it should be ~0). In some other architecutres it throws a BUG() on
> with
> dma_mapping_error() checks. So the patch is not a total bogus in some
> architectures :(.
> 
> May be it is best to create an internal FLAG in IXGBE_RSC_CB(skb)
> which can be used to avoid this double freeing. 

I suppose if Linus reads that he'll just come back and say "you idiots,
just make 0 invalid everywhere" like he did for interrupts tho :-) It
wouldn't be too hard for us to make the IOMMU allocator always skip "0".

But for now, I'd suggest you add a flag.

Cheers,
Ben.
