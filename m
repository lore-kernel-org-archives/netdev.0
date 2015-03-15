From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [v1 PATCH 4/14] tipc: Use rhashtable max_size instead of max_shift
Date: Sun, 15 Mar 2015 18:13:31 +0300
Message-ID: <5505A19B.4030402@cogentembedded.com>
References: <20150315104306.GA21999@gondor.apana.org.au> <E1YX620-0005n3-Uy@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:32948 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545AbbCOPNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 11:13:34 -0400
Received: by lbbzq9 with SMTP id zq9so16792590lbb.0
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 08:13:33 -0700 (PDT)
In-Reply-To: <E1YX620-0005n3-Uy@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/15/2015 1:44 PM, Herbert Xu wrote:

> This patch converts tipc to use rhashtable max_size instead of
> the obsolete max_shift.

    You're converting 'min_shift' to 'min_size' as well...

> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---

>   net/tipc/socket.c |    4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)

> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index 934947f..64eb669 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -2361,8 +2361,8 @@ int tipc_sk_rht_init(struct net *net)
>   		.key_offset = offsetof(struct tipc_sock, portid),
>   		.key_len = sizeof(u32), /* portid */
>   		.hashfn = jhash,
> -		.max_shift = 20, /* 1M */
> -		.min_shift = 8,  /* 256 */
> +		.max_size = 1048576,
> +		.min_size = 256,
>   	};
>
>   	return rhashtable_init(&tn->sk_rht, &rht_params);

WBR, Sergei
