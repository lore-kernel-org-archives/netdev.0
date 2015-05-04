From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH net-next v3 3/9] ipv6: Combine rt6_alloc_cow and
 rt6_alloc_clone
Date: Mon, 4 May 2015 10:08:27 -0700
Message-ID: <20150504170826.GH2731450@devbig242.prn2.facebook.com>
References: <1430526418-3132761-1-git-send-email-kafai@fb.com>
 <1430526418-3132761-4-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60409 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750941AbbEDRKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 13:10:12 -0400
Content-Disposition: inline
In-Reply-To: <1430526418-3132761-4-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 01, 2015 at 05:26:52PM -0700, Martin KaFai Lau wrote:
>  static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table, int oif,
>  				      struct flowi6 *fl6, int flags)
>  {
> @@ -918,10 +914,9 @@ redo_rt6_select:
>  	if (rt->rt6i_flags & RTF_CACHE)
>  		goto out2;
>  
> -	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
> -		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
> -	else if (!(rt->dst.flags & DST_HOST) || !(rt->dst.flags & RTF_LOCAL))
> -		nrt = rt6_alloc_clone(rt, &fl6->daddr);
> +	if (!rt6_is_gw_or_nonexthop(rt) ||
> +	    !(rt->dst.flags & DST_HOST) || !(rt->dst.flags & RTF_LOCAL))
It inherited a similar typo here which has already been fixed in net-next.
rt->dst.flags instead of rt->rt6i_flags is used when checking the RTF_LOCAL
flag.  The other patches are still good for review purpose.  I will re-post this
series later.

--Martin
