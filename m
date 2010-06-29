From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: uninitialized memory access in tcp_parse_options
Date: Mon, 28 Jun 2010 21:22:41 -0700 (PDT)
Message-ID: <20100628.212241.245398923.davem@davemloft.net>
References: <1277127249.9469.53.camel@localhost.localdomain>
	<1277531884.2481.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mathieu.lacage@sophia.inria.fr, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54407
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750699Ab0F2EW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 00:22:28 -0400
In-Reply-To: <1277531884.2481.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 26 Jun 2010 07:58:04 +0200

> If you want to avoid valgrind false positive at this point, without
> introducing bug for other tcp_parse_options() callers, a better fix
> would be following patch.
> 
> Thanks
> 
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index 794c2e1..4e758ac 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -520,14 +520,13 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
>  			   struct request_sock *req,
>  			   struct request_sock **prev)
>  {
> -	struct tcp_options_received tmp_opt;
> +	struct tcp_options_received tmp_opt = {0};
>  	u8 *hash_location;
>  	struct sock *child;

That's a 28 byte memset() in the connect fast-path.  We shouldn't eat this
just to placate a valgrind miscue. :-)


