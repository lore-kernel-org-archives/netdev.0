From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC(v2) net-next 09/13] ipv6: Do not depend on rt->n in rt6_check_neigh().
Date: Wed, 16 Jan 2013 14:53:55 +0800
Message-ID: <50F64E83.3000200@gmail.com>
References: <50F587D4.6060208@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:45040 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251Ab3APGyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 01:54:07 -0500
Received: by mail-da0-f48.google.com with SMTP id k18so432420dae.35
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 22:54:05 -0800 (PST)
In-Reply-To: <50F587D4.6060208@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/2013 12:46 AM, YOSHIFUJI Hideaki wrote:
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>   net/ipv6/route.c |   15 ++++++++++-----
>   1 file changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index e16a483..ffdc8a6 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -552,20 +552,25 @@ static inline bool rt6_check_neigh(struct rt6_info *rt)
>   	struct neighbour *neigh;
>   	bool ret = false;
>   
> -	neigh = rt->n;
>   	if (rt->rt6i_flags & RTF_NONEXTHOP ||
> -	    !(rt->rt6i_flags & RTF_GATEWAY))
> +	    !(rt->rt6i_flags & RTF_GATEWAY)) {
>   		ret = true;
> -	else if (neigh) {
> -		read_lock_bh(&neigh->lock);
> +		goto out;
> +	}

Just return true here...
