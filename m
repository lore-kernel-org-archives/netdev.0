From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [PATCH 12/13] TProxy: added IPv6 support to the socket match
Date: Tue, 22 Sep 2009 08:33:51 +0200
Message-ID: <1253601231.6883.1.camel@bzorp.balabit>
References: <1253548005.12519.12.camel@bzorp.balabit>
	 <4AB7BEF8.5050800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4AB7BEF8.5050800@hp.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-09-21 at 13:59 -0400, Brian Haley wrote:
> Balazs Scheidler wrote:
> > +static bool
> > +socket_mt6_v1(const struct sk_buff *skb, const struct xt_match_param *par)
> > +{
> > +	struct ipv6hdr *iph = ipv6_hdr(skb);
> > +	struct udphdr _hdr, *hp = NULL;
> > +	struct sock *sk;
> > +	struct in6_addr *daddr, *saddr;
> > +	__be16 dport, sport;
> > +        int thoff;
> > +	u8 tproto;
> > +        const struct xt_socket_mtinfo1 *info = (struct xt_socket_mtinfo1 *) par->matchinfo;
> > +        
> > +        tproto = ipv6_find_hdr(skb, &thoff, -1, NULL);
> > +        if (tproto < 0) {
> > +		pr_debug("socket match: Unable to find transport header in IPv6 packet, dropping\n");
> > +		return NF_DROP;
> > +        }
> > +
> > +	if (tproto == IPPROTO_UDP || tproto == IPPROTO_TCP) {
> > +		hp = skb_header_pointer(skb, thoff,
> > +					sizeof(_hdr), &_hdr);
> > +		if (hp == NULL)
> > +			return false;
> > +
> > +		saddr = &iph->saddr;
> > +		sport = hp->source;
> > +		daddr = &iph->daddr;
> > +		dport = hp->dest;
> > +
> > +	} else if (tproto == IPPROTO_ICMP) {
> > +		if (extract_icmp6_fields(skb, thoff, &tproto, &saddr, &daddr,
> > +					 &sport, &dport))
> > +			return false;
> > +	} else {
> > +		return false;
> > +	}
> 
> Shouldn't this be IPPROTO_ICMPV6?

Yeah, thanks for spotting this. I'm going to have to add ICMP checks to
my test program, or at least retest that functionality manually.

-- 
Bazsi

