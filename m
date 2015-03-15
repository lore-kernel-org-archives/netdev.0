From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [v1 PATCH 2/14] rhashtable: Introduce max_size/min_size
Date: Sun, 15 Mar 2015 18:12:02 +0300
Message-ID: <5505A142.6020606@cogentembedded.com>
References: <20150315104306.GA21999@gondor.apana.org.au> <E1YX61y-0005mR-MK@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:35496 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793AbbCOPMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 11:12:06 -0400
Received: by lbcgn8 with SMTP id gn8so5919884lbc.2
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 08:12:05 -0700 (PDT)
In-Reply-To: <E1YX61y-0005mR-MK@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/15/2015 1:44 PM, Herbert Xu wrote:

> This patch adds the parameters max_size and min_size which are
> meant to replace max_shift and min_shift.

> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

[...]
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index 4a99c0c..5101e18 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
[...]
> @@ -872,7 +874,8 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_stop);
>   static size_t rounded_hashtable_size(struct rhashtable_params *params)
>   {
>   	return max(roundup_pow_of_two(params->nelem_hint * 4 / 3),
> -		   1UL << params->min_shift);
> +		   max(1UL << params->min_shift,

    max_t(), perhaps?

> +		       (unsigned long)params->min_size));
>   }
>
>   /**
[...]

WBR, Sergei
