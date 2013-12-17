From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Tue, 17 Dec 2013 11:25:48 +0800
Message-ID: <52AFC43C.9080804@cn.fujitsu.com>
References: <1387182666-31301-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: roy.qing.li@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:40698 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751551Ab3LQD1t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 22:27:49 -0500
In-Reply-To: <1387182666-31301-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2013 04:31 PM, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> The commit ecd9883724b [ipv6: fix race condition regarding dst->expires and
> dst->from.] removed rt6_clean_expires in ip6_rt_copy, which causes the TAHI
> test case v6LC.4.1.4 { Reduce PMTU On-link } failed, since the newly generated
> rt maybe always expired {with RTF_EXPIRES flag, dst.expires is 0, and dst.from
> is NULL}.
> 
> Fix it by clearing RTF_EXPIRES as before 1716a96101[ipv6: fix problem with
> expired dst cache]
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/ipv6/route.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index a1a5752..e3d7f21 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1908,7 +1908,7 @@ static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
>  			rt->rt6i_gateway = ort->rt6i_gateway;
>  		else
>  			rt->rt6i_gateway = *dest;
> -		rt->rt6i_flags = ort->rt6i_flags;
> +		rt->rt6i_flags = ort->rt6i_flags & ~RTF_EXPIRES;
>  		if ((ort->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) ==
>  		    (RTF_DEFAULT | RTF_ADDRCONF))
>  			rt6_set_from(rt, ort);
> 

I don't understand, rt6_set_from already clears the RTF_EXPIRES from rt->rt6i_flags.
