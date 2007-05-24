From: Marc St-Jean <Marc_St-Jean@pmc-sierra.com>
Subject: Re: [PATCH 10/12] drivers: PMC MSP71xx ethernet driver
Date: Thu, 24 May 2007 15:13:26 -0700
Message-ID: <46560E06.9090506@pmc-sierra.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Marc St-Jean <stjeanma@pmc-sierra.com>, akpm@linux-foundation.org,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mother.pmc-sierra.com ([216.241.224.12]:61386 "HELO
	mother.pmc-sierra.bc.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751151AbXEXWNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 18:13:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Marc St-Jean wrote:
>  > +inline static void
>  > +mspeth_skb_headerinit(struct sk_buff *skb)
>  > +{
>  > +     /* these are essential before init */
>  > +     dst_release(skb->dst);
>  > +#ifdef CONFIG_XFRM
>  > +     secpath_put(skb->sp);
>  > +#endif
>  > +#ifdef CONFIG_NETFILTER
>  > +     nf_conntrack_put(skb->nfct);
>  > +#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
>  > +     nf_conntrack_put_reasm(skb->nfct_reasm);
>  > +#endif
>  > +#ifdef CONFIG_BRIDGE_NETFILTER
>  > +     nf_bridge_put(skb->nf_bridge);
>  > +#endif
>  > +#endif /* CONFIG_NETFILTER */
>  > +
>  > +     /*
>  > +      * Now initialise the skb...
>  > +      * Clear the members till skb->truesize.
>  > +      */
>  > +     memset(skb, 0, offsetof(struct sk_buff, truesize));
>  > +}
>  > +#endif /* CONFIG_MSPETH_SKB_RECYCLE */
> 
> Did you ever resend this driver addition, with the above unmaintainable
> skb init hacks removed?
> 
>         Jeff
> 

I removed the section you originally refererd to as it was associated with the
linux 2.4 support which was also removed.

I asked if the remaining section (above) was acceptable so we could retain our
buffer recycling which enhances throughput. I never received a rely so it was
left in my last patch.

The above comment now answers my part of my initial question. Are you aware of
a better way to implement this or must we lose all our recycling enhancements?

Thanks,
Marc
