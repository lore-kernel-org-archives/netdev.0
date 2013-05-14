From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2 net 1/2] sfc: Delete EFX_PAGE_IP_ALIGN, equivalent to
 NET_IP_ALIGN
Date: Tue, 14 May 2013 14:48:43 +0100
Message-ID: <1368539323.4304.81.camel@deadeye.wl.decadent.org.uk>
References: <1368482311.3305.48.camel@bwh-desktop.uk.solarflarecom.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7235@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	<linux-net-drivers@solarflare.com>,
	Linux Kernel Development <linux-kernel@vger.kernel.org>,
	<linux-s390@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7235@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-14 at 09:32 +0100, David Laight wrote:
> > The two architectures that define CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
> > (powerpc and x86) now both define NET_IP_ALIGN as 0, so there is no
> > need for this optimisation any more.
> 
> Hmmm.... even on x86 there will be a measurable cost
> in misaligned accesses - at least for some workloads.

When they cross cache-line boundaries, yes.

Maybe napi_get_frags() should be adding the 2 byte offset on all
architectures, as the skbs it allocates are never RX DMA buffers.

> If the DMA is able to write to a mis-aligned buffer and
> still perform aligned burst transfers mid-frame then
> 4n+2 aligning the rx buffer should be a win even on x86.

I don't think so.

> Note to hardware engineers: add an option to write two
> bytes of junk before the rx data :-)

There is some hardware with that option.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
