From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH net-next v2] net: Initialize table in fib result
Date: Thu, 17 Sep 2015 09:00:52 +0900
Message-ID: <20150917000052.GA421@swordfish>
References: <1442420199-51715-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sergey.senozhatsky.work@gmail.com,
	richard.alpe@ericsson.com, festevam@gmail.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35692 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952AbbIQAAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 20:00:07 -0400
Received: by pacfv12 with SMTP id fv12so2402252pac.2
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 17:00:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1442420199-51715-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/16/15 10:16), David Ahern wrote:
[..]
> The root cause is use of res.table uninitialized.
> 
> Thanks to Nikolay for noticing the uninitialized use amongst the maze of
> gotos.
> 
> As Nikolay pointed out the second initialization is not required to fix
> the oops, but rather to fix a related problem where a valid lookup should
> be invalidated before creating the rth entry.
> 
> Fixes: b7503e0cdb5d ("net: Add FIB table id to rtable")
> Reported-by: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

works for me, thanks

Tested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> Reported-by: Richard Alpe <richard.alpe@ericsson.com>
> Reported-by: Fabio Estevam <festevam@gmail.com>
> Tested-by: Fabio Estevam <fabio.estevam@freescale.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2:
> - clarification in the commit message regarding the second initialization
> 
>  net/ipv4/route.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index da427a4a33fe..80f7c5b7b832 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1712,6 +1712,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>  		goto martian_source;
>  
>  	res.fi = NULL;
> +	res.table = NULL;
>  	if (ipv4_is_lbcast(daddr) || (saddr == 0 && daddr == 0))
>  		goto brd_input;
>  
> @@ -1834,6 +1835,7 @@ out:	return err;
>  	RT_CACHE_STAT_INC(in_no_route);
>  	res.type = RTN_UNREACHABLE;
>  	res.fi = NULL;
> +	res.table = NULL;
>  	goto local_input;
>  
>  	/*
> -- 
> 2.3.2 (Apple Git-55)
> 
