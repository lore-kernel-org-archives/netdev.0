From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 3/5] ipv6: Stop /128 route from disappearing
 after pmtu update
Date: Sat, 2 May 2015 18:03:33 -0700
Message-ID: <20150503010333.GD2731450@devbig242.prn2.facebook.com>
References: <1430251387-2942539-1-git-send-email-kafai@fb.com>
 <1430251387-2942539-4-git-send-email-kafai@fb.com>
 <m2d22itxe2.wl@sfc.wide.ad.jp>
 <20150502232040.GB2731450@devbig242.prn2.facebook.com>
 <m2bni2tsv0.wl@sfc.wide.ad.jp>
 <20150503010055.GC2731450@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <hannes@stressinduktion.org>,
	<steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<yangyingliang@huawei.com>, <shengyong1@huawei.com>,
	<Kernel-team@fb.com>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46701 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750913AbbECBDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 21:03:51 -0400
Content-Disposition: inline
In-Reply-To: <20150503010055.GC2731450@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 02, 2015 at 06:00:55PM -0700, Martin KaFai Lau wrote:
> Can you try this patch just to confirm:
> 
> Thanks
> --Martin
> 
> diff --git i/net/ipv6/route.c w/net/ipv6/route.c
> index 3522711..c0ae180 100644
> --- i/net/ipv6/route.c
> +++ w/net/ipv6/route.c
> @@ -920,7 +920,7 @@ redo_rt6_select:
> 
>  	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
>  		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
> -	else if (!(rt->dst.flags & DST_HOST) || !(rt->dst.flags & RTF_LOCAL))
> +	else if (!(rt->dst.flags & DST_HOST)))
>  		nrt = rt6_alloc_clone(rt, &fl6->daddr);
>  	else
>  		goto out2;

Sorry for the noise, try this one instead

diff --git i/net/ipv6/route.c w/net/ipv6/route.c
index 3522711..f81b321 100644
--- i/net/ipv6/route.c
+++ w/net/ipv6/route.c
@@ -920,7 +920,7 @@ redo_rt6_select:

 	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
-	else if (!(rt->dst.flags & DST_HOST) || !(rt->dst.flags & RTF_LOCAL))
+	else if (!(rt->dst.flags & DST_HOST))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
 	else
 		goto out2;
