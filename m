From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC 0/7] Fixing dma mask setting in various
	network drivers
Date: Wed, 12 Jun 2013 01:01:23 +0100
Message-ID: <20130612000123.GP18614@n2100.arm.linux.org.uk>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk>
	<20130611111230.000062d2@unknown>
	<20130611203505.GO18614@n2100.arm.linux.org.uk>
	<20130611165044.00000d3a@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rasesh Mody <rmody@brocade.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20130611165044.00000d3a@unknown>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Jun 11, 2013 at 04:50:44PM -0700, Jesse Brandeburg wrote:
> On Tue, 11 Jun 2013 13:35:05 -0700
> Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
> > As part of my review of all this stuff, I'm wondering whether a helper
> > to set both masks makes sense.  Something like:
> > 
> > static inline int dma_set_masks(struct device *dev, u64 mask)
> 
> it doesn't need to be inline, it is never called in hotpath.

If it goes into linux/dma-mapping.h as a simple helper it does, otherwise
you'll get "declared but not used" warnings.

> > {
> > 	int ret = dma_set_mask(dev, mask);
> > 	if (ret == 0)
> > 		dma_set_coherent_mask(dev, mask);
> > 	return ret;
> > }
> > 
> > "dma_set_masks()" is a little too close to dma_set_mask() though; and
> 
> how about dma_set_mask_and_coherent(...)

Yea, I'm happy with that.

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
