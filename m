From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 5/7] net: add netfilter ingress hook
Date: Fri, 10 Apr 2015 22:08:08 +0200
Message-ID: <20150410200808.GA5968@salvia>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
 <1428668142-4006-6-git-send-email-pablo@netfilter.org>
 <20150410132120.GE23070@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, kaber@trash.net,
	netdev@vger.kernel.org, davem@davemloft.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150410132120.GE23070@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 10, 2015 at 02:21:20PM +0100, Thomas Graf wrote:
> On 04/10/15 at 02:15pm, Pablo Neira Ayuso wrote:
> >  static int __netif_receive_skb_ingress(struct sk_buff *skb, bool pfmemalloc,
> >  				       struct net_device *orig_dev)
> >  {
> > @@ -3772,6 +3800,8 @@ skip_taps:
> >  	if (!skb)
> >  		return NET_RX_DROP;
> >  #endif
> > +	if (nf_hook_ingress_active(skb))
> > +		return nf_hook_ingress(skb, pt_prev, orig_dev, pfmemalloc);
> >  
> >  	return __netif_receive_skb_finish(skb, pfmemalloc, pt_prev, orig_dev);
> >  }
> 
> I would favour if we avoid for every subsystem to manage its ingress
> filter pointers in net_device. From a net_device perspective, all it
> takes is a single pointer which points to a single linked list of
> filters which need to be run through. These entries could represent
> an ingress qdisc or a netfilter chain or something else (L2 ingress
> qdisc?).
> 
> I know it's only 24 bytes but I'm trying hard to keep net_device below
> 2K.

Then it would be probably good to investigate if we can come up with
some extension infrastructure for net_device (I think Patrick already
suggested this during netdev0.1), so things are allocated based on
available features.
