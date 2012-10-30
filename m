From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] net: allow configuration of the size of
 page in __netdev_alloc_frag
Date: Tue, 30 Oct 2012 13:23:52 -0400
Message-ID: <20121030172352.GA31997@phenom.dumpdata.com>
References: <1351078936-14159-1-git-send-email-ian.campbell@citrix.com>
	<1351081703.6537.99.camel@edumazet-glaptop>
	<1351084618.18035.27.camel@zakaz.uk.xensource.com>
	<1351085403.6537.102.camel@edumazet-glaptop>
	<1351087326.18035.50.camel@zakaz.uk.xensource.com>
	<1351092068.6537.107.camel@edumazet-glaptop>
	<1351095739.18035.83.camel@zakaz.uk.xensource.com>
	<1351097000.6537.109.camel@edumazet-glaptop>
	<20121030165309.GA30483@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <xen-devel-bounces@lists.xen.org>
Content-Disposition: inline
In-Reply-To: <20121030165309.GA30483@phenom.dumpdata.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2012 at 12:53:09PM -0400, Konrad Rzeszutek Wilk wrote:
> On Wed, Oct 24, 2012 at 06:43:20PM +0200, Eric Dumazet wrote:
> > On Wed, 2012-10-24 at 17:22 +0100, Ian Campbell wrote:
> > > On Wed, 2012-10-24 at 16:21 +0100, Eric Dumazet wrote:
> > 
> > > > If you really have such problems, why locally generated TCP traffic
> > > > doesnt also have it ?
> > > 
> > > I think it does. The reason I noticed the original problem was that ssh
> > > to the machine was virtually (no pun intended) unusable.
> > > 
> > > > Your patch doesnt touch sk_page_frag_refill(), does it ?
> > > 
> > > That's right. It doesn't. When is (sk->sk_allocation & __GFP_WAIT) true?
> > > Is it possible I'm just not hitting that case?
> > > 
> > 
> > I hope not. GFP_KERNEL has __GFP_WAIT.
> > 
> > > Is it possible that this only affects certain traffic patterns (I only
> > > really tried ssh/scp and ping)? Or perhaps its just that the swiotlb is
> > > only broken in one corner case and not the other.
> > 
> > Could you try a netperf -t TCP_STREAM ?
> 
> For fun I did a couple of tests - I setup two machines (one r8168, the other
> e1000e) and tried to do netperf/netserver. Both of them are running a baremetal
> kernel and one of them has 'iommu=soft swiotlb=force' to simulate the worst
> case. This is using v3.7-rc3.

I also did a test with the patch at the top, with the same setup and ... it
does look like it fixes some issues, but not the underlaying one.

The same test, with net.core.netdev_frag_page_max_order=0, the e1000e->r8169
gets ~124, but then on subsequent runs it picks up to ~933. If I let the
machine stay a bit idle and then do this again, it does around ~124 again.

Thoughts?
