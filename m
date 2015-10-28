From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: new coverity defect in ipv6 route
Date: Wed, 28 Oct 2015 03:14:04 +0100
Message-ID: <1445998444.586814.422132817.384693E6@webmail.messagingengine.com>
References: <20151028094330.1acb02db@samsung9>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:55271 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751549AbbJ1COF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 22:14:05 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 75684203C1
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 22:14:04 -0400 (EDT)
In-Reply-To: <20151028094330.1acb02db@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Wed, Oct 28, 2015, at 01:43, Stephen Hemminger wrote:
________________________________________________________________________________________________________
> *** CID 1328821:  Memory - corruptions  (ARRAY_VS_SINGLETON)
> /net/ipv6/route.c: 320 in rt6_info_init()
> 314     #endif
> 315     
> 316     static void rt6_info_init(struct rt6_info *rt)
> 317     {
> 318             struct dst_entry *dst = &rt->dst;
> 319     
> >>>     CID 1328821:  Memory - corruptions  (ARRAY_VS_SINGLETON)
> >>>     Using "dst" as an array.  This might corrupt or misinterpret adjacent memory locations.
> 320             memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
> 321             INIT_LIST_HEAD(&rt->rt6i_siblings);
> 322             INIT_LIST_HEAD(&rt->rt6i_uncached);
> 323     }
> 324     
> 325     /* allocate dst with ip6_dst_ops */

I already marked this as an false positive in coverity.

Thanks,
Hannes
