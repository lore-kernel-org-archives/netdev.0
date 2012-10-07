From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: gro: selective flush of packets
Date: Sun, 7 Oct 2012 08:32:09 +0800
Message-ID: <20121007003208.GA31839@gondor.apana.org.au>
References: <1348841041.5093.2477.camel@edumazet-glaptop>
 <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
 <1349448747.21172.113.camel@edumazet-glaptop>
 <20121006041155.GA27134@gondor.apana.org.au>
 <1349500126.4883.4.camel@edumazet-laptop>
 <20121006051407.GA27390@gondor.apana.org.au>
 <1349504541.21172.183.camel@edumazet-glaptop>
 <1349506825.21172.241.camel@edumazet-glaptop>
 <20121006105618.GA28591@gondor.apana.org.au>
 <1349546929.21172.1598.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:57228 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750954Ab2JGAcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2012 20:32:16 -0400
Content-Disposition: inline
In-Reply-To: <1349546929.21172.1598.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 06, 2012 at 08:08:49PM +0200, Eric Dumazet wrote:
>
> @@ -3981,8 +3996,17 @@ static void net_rx_action(struct softirq_action *h)
>  				local_irq_enable();
>  				napi_complete(n);
>  				local_irq_disable();
> -			} else
> +			} else {
> +				if (n->gro_list) {
> +					/* flush too old packets
> +					 * If HZ < 1000, flush all packets.
> +					 */
> +					local_irq_enable();
> +					napi_gro_flush(n, HZ >= 1000);
> +					local_irq_disable();
> +				}
>  				list_move_tail(&n->poll_list, &sd->poll_list);
> +			}

Why don't we just always flush everything?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
