From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: bnx2 fails to compile on parisc because of missing
 get_dma_ops()
Date: Wed, 23 Jun 2010 09:38:27 +0900
Message-ID: <20100623093638R.fujita.tomonori@lab.ntt.co.jp>
References: <20100617153051.GB8964@linux-sh.org>
	<20100622152823R.fujita.tomonori@lab.ntt.co.jp>
	<1277227564.9374.7.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, lethal@linux-sh.org,
	davem@davemloft.net, mchan@broadcom.com, vapier@gentoo.org,
	netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: James.Bottomley@HansenPartnership.com
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <1277227564.9374.7.camel@mulgrave.site>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Jun 2010 12:26:04 -0500
James Bottomley <James.Bottomley@HansenPartnership.com> wrote:

> > As I wrote, there is only one user of this API and we can remove it
> > easily. Then I'm not sure it's worth fixing dma_is_consistent() in
> > many architectures. I prefer to add this to
> > feature-removal-schedule.txt to see if driver writers oppose.
> 
> Let me check our two drivers: lasi and 53c700; they're the only ones we
> support on the architecture that can't do any coherence.  I think we
> don't need to tell because the dma_sync_cache calls which replace
> coherent memory handling are indirected on the platform so we don't need
> a global dma_is_coherent() flag.

There is only one place where 53c700 uses dma_is_consistent() (lasi
doesn't use it):

	BUG_ON(!dma_is_consistent(hostdata->dev, pScript) && L1_CACHE_BYTES < dma_get_cache_alignment());

I think that we can remove the above checking since the existing
parisc systems that can't allocate coherent memory pass this checking.

53c700 and lasi call dma_cache_sync() unconditionally so we can live
without dma_is_consistent().
