From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [RFC 0/7] Fixing dma mask setting in various
	network drivers
Date: Tue, 11 Jun 2013 16:50:44 -0700
Message-ID: <20130611165044.00000d3a@unknown>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk>
	<20130611111230.000062d2@unknown>
	<20130611203505.GO18614@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rasesh Mody <rmody@brocade.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	jesse.brandeburg@intel.com, "Ronciak, John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130611203505.GO18614@n2100.arm.linux.org.uk>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 11 Jun 2013 13:35:05 -0700
Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
> As part of my review of all this stuff, I'm wondering whether a helper
> to set both masks makes sense.  Something like:
> 
> static inline int dma_set_masks(struct device *dev, u64 mask)

it doesn't need to be inline, it is never called in hotpath.

> {
> 	int ret = dma_set_mask(dev, mask);
> 	if (ret == 0)
> 		dma_set_coherent_mask(dev, mask);
> 	return ret;
> }
> 
> "dma_set_masks()" is a little too close to dma_set_mask() though; and

how about dma_set_mask_and_coherent(...)

> such a function looks like it would be usable for 20 odd drivers
> currently.  The plus point is that it may help to prevent this kind
> of issue in the future...
> 
> Thoughts?

I really like the idea of consolidating this in the kernel with a
global helper.


------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
