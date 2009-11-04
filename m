From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] ip_frag:
Date: Wed, 04 Nov 2009 14:00:51 -0800
Message-ID: <1257372051.24051.8.camel@Joe-Laptop.home>
References: <4AF1F809.4090903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1239 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932717AbZKDWAr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 17:00:47 -0500
In-Reply-To: <4AF1F809.4090903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-11-04 at 22:54 +0100, Eric Dumazet wrote:
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> index 575f9bd..93e50d0 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -206,10 +206,10 @@ static void ip_expire(unsigned long arg)
>  		struct sk_buff *head = qp->q.fragments;
>  
>  		/* Send an ICMP "Fragment Reassembly Timeout" message. */
> -		if ((head->dev = dev_get_by_index(net, qp->iif)) != NULL) {
> +		rcu_read_lock();
> +		if ((head->dev = dev_get_by_index_rcu(net, qp->iif)) != NULL)
>  			icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
> -			dev_put(head->dev);
> -		}
> +		rcu_read_unlock();
>  	}

Hi Eric.  If you're going to do more of these, could you please
convert them to the more standard kernel style as well?

	var = func(foo);
	if (var) {
		etc...


