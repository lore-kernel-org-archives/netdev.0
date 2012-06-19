From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Mon, 18 Jun 2012 21:26:28 -0700 (PDT)
Message-ID: <20120618.212628.2164698406485633989.davem@davemloft.net>
References: <1340078846.7491.2127.camel@edumazet-glaptop>
	<20120618.211539.105938285016510975.davem@davemloft.net>
	<1340079813.7491.2164.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809Ab2FSE0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 00:26:30 -0400
In-Reply-To: <1340079813.7491.2164.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Jun 2012 06:23:33 +0200

> I was referring to socket leak in :
> 
> +       if (sk) {
> +               skb->sk = sk;
> +               skb->destructor = sock_edemux;
> +               if (sk->sk_state != TCP_TIME_WAIT) {
> +                       struct dst_entry *dst = sk->sk_rx_dst;
> +                       if (dst) {
> +                               skb_dst_set_noref(skb, dst);
> +                               err = 0;
> +                       }
> +               }
> +       }
> 

I see no leak.
