From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Fix IXP4xx coherent allocations
Date: Sun, 24 Mar 2013 22:15:36 +0100
Message-ID: <m3r4j4sdmv.fsf@intrepid.localdomain>
References: <m3obe9lxil.fsf@intrepid.localdomain>
	<20130323.195740.2108147521543354261.davem@davemloft.net>
	<1364152267.3620.31.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	c.aeschlimann@acn-group.ch, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364152267.3620.31.camel@deadeye.wl.decadent.org.uk> (Ben
	Hutchings's message of "Sun, 24 Mar 2013 19:11:07 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Hutchings <bhutchings@solarflare.com> writes:

> I'm failing to see where it says the default can't be narrower than 32
> bits due to platform limits.  And how do you think DMA mapping is
> supposed to work for PCI devices on these platforms, anyway?

The problem on ARM (and probably on powerpc, and on something called
"metag" - grep -r 'coherent DMA mask is unset' arch) is that the default
coherent DMA mask is zero. IOW, coherent DMA allocations are, by
default, disabled. A driver has to dma_set_coherent_mask() or, as many
drivers do, set dev->coherent_dma_mask directly (IMHO
dev->coherent_dma_mask along with dev->dma_mask are private DMA API
stuff and e.g. device drivers have no interest there).

The zero default is IMHO, WRT the actual DMA API, an ARM bug (and
powerpc's etc). Nevertheless, the patch I posted does everything as
required by the API. Specifically, the IXP4xx arch part makes
IXP4xx's dma_set_coherent_mask() compliant with DMA API, and the actual
dma_set_coherent_mask() calls in drivers are both valid and I guess
recommended by the API.

The patch doesn't touch the core ARM issue, that's right.
-- 
Krzysztof Halasa
