From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH]ipv6:remove useless check
Date: Tue, 14 Apr 2009 11:31:40 +0800
Message-ID: <49E4039C.5080908@cn.fujitsu.com>
References: <49E3EC04.5000105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, brian.haley@hp.com
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58662 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753068AbZDNDh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2009 23:37:56 -0400
In-Reply-To: <49E3EC04.5000105@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yang Hongyang said:
> After switch (rthdr->type) {...},the check below is completely useless.Because:
> if the type is 2,then hdrlen must be 2 and segments_left must be 1,clearly the
> check is redundant;if the type is not 2,then goto sticky_done,the check is useless
> too.
> 

Add CC  Brian Haley.

The check is defined only for Type 0 Routing header in section 4.4 of RFC2460: 

   Hdr Ext Len          8-bit unsigned integer.  Length of the Routing
                        header in 8-octet units, not including the first
                        8 octets.  For the Type 0 Routing header, Hdr
                        Ext Len is equal to two times the number of
                        addresses in the header.

Now, Type 0 Routing header has been removed, the check is redundant.

Reviewed-by: Shan Wei <shanwei@cn.fujitsu.com>

> Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com>
> 
> ---
>  net/ipv6/ipv6_sockglue.c |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index d31df0f..a7fdf9a 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -380,10 +380,6 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
>  			default:
>  				goto sticky_done;
>  			}
> -
> -			if ((rthdr->hdrlen & 1) ||
> -			    (rthdr->hdrlen >> 1) != rthdr->segments_left)
> -				goto sticky_done;
>  		}
>  
>  		retv = 0;

-- 
Best Regards
Shan Wei
