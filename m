From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: Re: [Xen-devel] [PATCH] net: allow configuration of the size of page
 in __netdev_alloc_frag
Date: Wed, 31 Oct 2012 07:01:51 -0400
Message-ID: <20121031110149.GA6376@localhost.localdomain>
References: <1351078936-14159-1-git-send-email-ian.campbell@citrix.com>
 <1351081703.6537.99.camel@edumazet-glaptop>
 <1351084618.18035.27.camel@zakaz.uk.xensource.com>
 <1351085403.6537.102.camel@edumazet-glaptop>
 <1351087326.18035.50.camel@zakaz.uk.xensource.com>
 <1351092068.6537.107.camel@edumazet-glaptop>
 <1351095739.18035.83.camel@zakaz.uk.xensource.com>
 <1351097000.6537.109.camel@edumazet-glaptop>
 <20121030165309.GA30483@phenom.dumpdata.com>
 <20121030172352.GA31997@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:33492 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756730Ab2JaLB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 07:01:58 -0400
Received: by mail-qc0-f174.google.com with SMTP id o22so826223qcr.19
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 04:01:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20121030172352.GA31997@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 30, 2012 at 01:23:52PM -0400, Konrad Rzeszutek Wilk wrote:
> On Tue, Oct 30, 2012 at 12:53:09PM -0400, Konrad Rzeszutek Wilk wrote:
> > On Wed, Oct 24, 2012 at 06:43:20PM +0200, Eric Dumazet wrote:
> > > On Wed, 2012-10-24 at 17:22 +0100, Ian Campbell wrote:
> > > > On Wed, 2012-10-24 at 16:21 +0100, Eric Dumazet wrote:
> > > 
> > > > > If you really have such problems, why locally generated TCP traffic
> > > > > doesnt also have it ?
> > > > 
> > > > I think it does. The reason I noticed the original problem was that ssh
> > > > to the machine was virtually (no pun intended) unusable.
> > > > 
> > > > > Your patch doesnt touch sk_page_frag_refill(), does it ?
> > > > 
> > > > That's right. It doesn't. When is (sk->sk_allocation & __GFP_WAIT) true?
> > > > Is it possible I'm just not hitting that case?
> > > > 
> > > 
> > > I hope not. GFP_KERNEL has __GFP_WAIT.
> > > 
> > > > Is it possible that this only affects certain traffic patterns (I only
> > > > really tried ssh/scp and ping)? Or perhaps its just that the swiotlb is
> > > > only broken in one corner case and not the other.
> > > 
> > > Could you try a netperf -t TCP_STREAM ?
> > 
> > For fun I did a couple of tests - I setup two machines (one r8168, the other
> > e1000e) and tried to do netperf/netserver. Both of them are running a baremetal
> > kernel and one of them has 'iommu=soft swiotlb=force' to simulate the worst
> > case. This is using v3.7-rc3.
> 
> I also did a test with the patch at the top, with the same setup and ... it
> does look like it fixes some issues, but not the underlaying one.
> 
> The same test, with net.core.netdev_frag_page_max_order=0, the e1000e->r8169
> gets ~124, but then on subsequent runs it picks up to ~933. If I let the
> machine stay a bit idle and then do this again, it does around ~124 again.
> 
> Thoughts?

Argh. Please disregard this test. I added an extra patch in the kernel
tree to track the SWIOTLB bounce usage and print it.. and the printk was
going out to the FB, which was not too fast - so the whole test was being
slowed down by FB drivers :-)

Will re-run this test without the offending patch.
