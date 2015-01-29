From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH RFC 1/2] ipv6: Fix after pmtu events dissapearing host
 routes
Date: Thu, 29 Jan 2015 11:26:51 +0100
Message-ID: <1422527211.2861.2.camel@redhat.com>
References: <54C78B8D.1070104@huawei.com>
	 <20150128121026.GM13046@secunet.com> <20150128121150.GN13046@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yang Yingliang <yangyingliang@huawei.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754269AbbA2K1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2015 05:27:09 -0500
In-Reply-To: <20150128121150.GN13046@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2015-01-28 at 13:11 +0100, Steffen Klassert wrote:
> We currently don't clone host routes before we use them.
> If a pmtu event is received on such a route, it gets
> an expires value. As soon as the expiration time is
> elapsed, the route is deleted. As a result, the host
> is not reachable any more.
> 
> We fix this by cloning host routes if they are gatewayed,
> i.e. if pmtu events can happen.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv6/route.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index c910831..3e864e7 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -961,7 +961,7 @@ redo_rt6_select:
>  
>  	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
>  		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
> -	else if (!(rt->dst.flags & DST_HOST))
> +	else if (!(rt->dst.flags & DST_HOST) || (rt->rt6i_flags & RTF_GATEWAY))
>  		nrt = rt6_alloc_clone(rt, &fl6->daddr);
>  	else
>  		goto out2;

My approach was to suppress mtu updates on the loopback interface.
Hmm...

Bye,
Hannes
