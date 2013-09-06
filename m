From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH] net/core: Order-3 frag allocator causes
 SWIOTLB bouncing under Xen
Date: Fri, 6 Sep 2013 09:27:10 -0400
Message-ID: <20130906132710.GI2590@phenom.dumpdata.com>
References: <1378327638-23956-1-git-send-email-zoltan.kiss@citrix.com>
 <1378328440.7360.124.camel@edumazet-glaptop>
 <20130904211110.GA17758@phenom.dumpdata.com>
 <1378366746.6935.35.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xen.org,
	Eric Dumazet <edumazet@google.com>,
	Li Zefan <lizefan@huawei.com>, david.vrabel@citrix.com,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	malcolm.crossley@citrix.com,
	"David S. Miller" <davem@davemloft.net>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1378366746.6935.35.camel@dagon.hellion.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 05, 2013 at 08:39:06AM +0100, Ian Campbell wrote:
> On Wed, 2013-09-04 at 17:11 -0400, Konrad Rzeszutek Wilk wrote:
> > On Wed, Sep 04, 2013 at 02:00:40PM -0700, Eric Dumazet wrote:
> 
> > > Maybe you could add proper infrastructure to deal with Xen limitations.
> > 
> > I think Ian posted at some point an sysctl patch for that (more for
> > debugging that anything else). And it kind
> > of stalled: http://lists.xen.org/archives/html/xen-devel/2012-10/msg01832.html
> 
> I think I though you were looking into it from the swiotlb angle?

Yes. I didn't find anything immediately obvious - but I can still
reproduce with an skge DMA issues when booting baremetal with 'swiotlb=force'.

But only under 32-bit. I think there is some physical address
truncation with the new compound size skb's. Obviously needs
further investigation.

> 
> In any case I don't have time to look into this further.
> 
> > Is that what you mean by proper infrastructure ?
> > 
> > Oh wait, did you mean via dev and not the whole system wide sysctl?
> 
> The system wide sysctl was not acceptable AFAIR, which seems reasonable.

<nods>
> 
> Per-dev is hard because it affects the native drivers for each physical
> NIC when running under Xen, not the Xen PV NIC which we fixed by
> splitting compound frags into separate slots on the PV ring.

Right. Thank you for pointing that obvious issue.

> 
> Ian.
> 
