From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 -next] netfilter: don't use per-destination
 incrementing ports in nat random mode
Date: Sat, 21 Dec 2013 13:27:51 +0100
Message-ID: <20131221122751.GA27268@localhost>
References: <20131219134007.GA24118@order.stressinduktion.org>
 <52B37F6B.9010105@redhat.com>
 <20131220004822.GC32129@order.stressinduktion.org>
 <20131220080118.GA4234@localhost>
 <20131220214029.GB14073@order.stressinduktion.org>
 <20131221121759.GA27158@localhost>
 <20131221122617.GF14073@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Daniel Borkmann <dborkman@redhat.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131221122617.GF14073@order.stressinduktion.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 21, 2013 at 01:26:17PM +0100, Hannes Frederic Sowa wrote:
> On Sat, Dec 21, 2013 at 01:17:59PM +0100, Pablo Neira Ayuso wrote:
> > > diff --git a/include/uapi/linux/netfilter/nf_nat.h b/include/uapi/linux/netfilter/nf_nat.h
> > > index bf0cc37..1ad3659 100644
> > > --- a/include/uapi/linux/netfilter/nf_nat.h
> > > +++ b/include/uapi/linux/netfilter/nf_nat.h
> > 
> > This is exposed to userspace.
> > 
> > > @@ -4,10 +4,14 @@
> > >  #include <linux/netfilter.h>
> > >  #include <linux/netfilter/nf_conntrack_tuple_common.h>
> > >  
> > > -#define NF_NAT_RANGE_MAP_IPS		1
> > > -#define NF_NAT_RANGE_PROTO_SPECIFIED	2
> > > -#define NF_NAT_RANGE_PROTO_RANDOM	4
> > > -#define NF_NAT_RANGE_PERSISTENT		8
> > > +#define NF_NAT_RANGE_MAP_IPS			(1 << 0)
> > > +#define NF_NAT_RANGE_PROTO_SPECIFIED		(1 << 1)
> > > +#define NF_NAT_RANGE_PROTO_RANDOM		(1 << 2)
> > > +#define NF_NAT_RANGE_PERSISTENT			(1 << 3)
> > > +#define NF_NAT_RANGE_PROTO_RANDOM_FULLY		(1 << 4)
> > 
> > So you cannot change it. It would break old iptables binaries.
> 
> There are no semantic changes besides the addition of
> NF_NAT_RANGE_PROTO_RANDOM_FULLY. Otherwise just the notation is changed,
> which looks sane to me.

My fault sorry. I overlooked that you were just converting from
numeric to flag notation.

This is fine.

> > BTW, please send me the userspace part.
> 
> Daniel has the patch ready, I think he will submit it later today.

Thanks.
