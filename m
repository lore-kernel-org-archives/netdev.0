From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Build regressions/improvements in v3.10-rc1 (s390)
Date: Mon, 13 May 2013 17:41:47 +0100
Message-ID: <1368463307.3305.23.camel@bwh-desktop.uk.solarflarecom.com>
References: <alpine.DEB.2.00.1305122130270.3789@ayla.of.borg>
	 <alpine.DEB.2.00.1305122239040.5463@ayla.of.borg>
	 <alpine.DEB.2.00.1305122250110.5463@ayla.of.borg>
	 <20130513074159.GA4290@osiris>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	<linux-net-drivers@solarflare.com>,
	Stuart Hodgson <smhodgson@solarflare.com>,
	Linux Kernel Development <linux-kernel@vger.kernel.org>,
	<linux-s390@vger.kernel.org>, <netdev@vger.kernel.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130513074159.GA4290@osiris>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-13 at 09:41 +0200, Heiko Carstens wrote:
> On Sun, May 12, 2013 at 10:50:45PM +0200, Geert Uytterhoeven wrote:
> > On Sun, 12 May 2013, Geert Uytterhoeven wrote:
> > > However, the full list of errors isn't that unmanageable, so I'm following
> > > up with a digested list...
> > 
> > drivers/net/ethernet/sfc/efx.c:646:3: error: call to '__compiletime_assert_648' declared with attribute error: BUILD_BUG_ON failed: sizeof(struct efx_rx_page_state) + EFX_PAGE_IP_ALIGN + EFX_RX_USR_BUF_SIZE > PAGE_SIZE / 2: 2 errors in 2 logs
> > 	v3.10-rc1/s390x/s390-allyesconfig v3.10-rc1/s390x/s390-allmodconfig
> 
> that seems to a BUILD_BUG_ON that only triggers on s390, because we have
> L1_CACHE_BYTES defined with 256 bytes... which seems to be more than any
> other architecture has.
> There was a different network driver that had a similar BUILD_BUG_ON, but
> it got removed.
> 
> Right, it was the igb driver:
> http://comments.gmane.org/gmane.linux.network/261378

The critical value here is EFX_RX_USR_BUF_SIZE.  The hardware constrains
it to be a multiple of 32, but for performance reasons it also ought to
be a multiple of the cache line size(s).  In our internal development
branch it has already been reduced to 1792, which is a multiple of 256
and should satisfy the BUILD_BUG_ON check.  I'll post a patch shortly.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
