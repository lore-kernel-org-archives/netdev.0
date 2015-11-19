From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net: remove useless check in napi_gro_frags()
Date: Thu, 19 Nov 2015 11:54:20 -0800
Message-ID: <20151119195419.GA6728@ast-mbp.thefacebook.com>
References: <1447962170.22599.240.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33923 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759068AbbKSTyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:54:23 -0500
Received: by padhx2 with SMTP id hx2so90661165pad.1
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:54:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1447962170.22599.240.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015 at 11:42:50AM -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Checking if skb is NULL in napi_gro_frags() is too late.
> 
> If skb was NULL, we would crash earlier in napi_frags_skb()
> 
> Drivers normally catch napi_get_frags() NULL return value
> before calling napi_gro_frags()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/core/dev.c |    3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 41cef3e3f558b857a9093a83f6b0c73f32b8b45f..8d8d34ff68f5800dbcb2958b6a937b9db478e359 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4465,9 +4465,6 @@ gro_result_t napi_gro_frags(struct napi_struct *napi)
>  {
>  	struct sk_buff *skb = napi_frags_skb(napi);
>  
> -	if (!skb)
> -		return GRO_DROP;
> -

I don't get it. napi_frags_skb() can return valid NULL.
Should it be fixed there as well?
Must be missing something...
