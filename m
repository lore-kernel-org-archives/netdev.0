From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [Xen-devel] [RFC 21/23] net/xen-netback: Make it running on
 64KB page granularity
Date: Fri, 15 May 2015 16:41:51 +0100
Message-ID: <1431704511.8943.148.camel@citrix.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
	 <1431622863-28575-22-git-send-email-julien.grall@citrix.com>
	 <20150515023534.GE19352@zion.uk.xensource.com>
	 <5555E81E.8070803@citrix.com> <20150515153143.GA8521@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julien Grall <julien.grall@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <netdev@vger.kernel.org>,
	<tim@xen.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150515153143.GA8521@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-05-15 at 16:31 +0100, Wei Liu wrote:
> On Fri, May 15, 2015 at 01:35:42PM +0100, Julien Grall wrote:
> > Hi Wei,
> > 
> > Thanks you for the review.
> > 
> > On 15/05/15 03:35, Wei Liu wrote:
> > > On Thu, May 14, 2015 at 06:01:01PM +0100, Julien Grall wrote:
> > >> The PV network protocol is using 4KB page granularity. The goal of this
> > >> patch is to allow a Linux using 64KB page granularity working as a
> > >> network backend on a non-modified Xen.
> > >>
> > >> It's only necessary to adapt the ring size and break skb data in small
> > >> chunk of 4KB. The rest of the code is relying on the grant table code.
> > >>
> > >> Although only simple workload is working (dhcp request, ping). If I try
> > >> to use wget in the guest, it will stall until a tcpdump is started on
> > >> the vif interface in DOM0. I wasn't able to find why.
> > >>
> > > 
> > > I think in wget workload you're more likely to break down 64K pages to
> > > 4K pages. Some of your calculation of mfn, offset might be wrong.
> > 
> > If so, why tcpdump on the vif interface would make wget suddenly
> > working? Does it make netback use a different path?
> 
> No, but if might make core network component behave differently, this is
> only my suspicion.

Traffic being delivered to dom0 (as opposed to passing through a bridge
and going elsewhere) will get skb_orphan_frags called on it, since
tcpdump ends up cloning the skb to go to two places it's not out of the
question that this might have some impact (deliberate or otherwise) on
the other skb which isn't going to dom0.

Ian.
