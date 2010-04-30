From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: [PATCH net-next-2.6] net: sock_def_readable() and friends RCU
 conversion
Date: Fri, 30 Apr 2010 09:55:34 -0400
Message-ID: <4BDAE156.8070800@athenacr.com>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>	 <20100427.150817.84390202.davem@davemloft.net>	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>	 <1272547307.2222.83.camel@edumazet-laptop> <1272548258.4258.185.camel@bigi>	 <1272548980.2222.87.camel@edumazet-laptop> <1272549408.4258.189.camel@bigi>	 <1272573383.3969.8.camel@bigi> <1272574909.2209.150.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:64961 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758563Ab0D3R0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:26:46 -0400
In-Reply-To: <1272574909.2209.150.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Here is last 'patch of the day' for me ;)
> Next one will be able to coalesce wakeup calls (they'll be delayed at
> the end of net_rx_action(), like a patch I did last year to help
> multicast reception)
>
> vger seems to be down, I suspect I'll have to resend it later.
>
> [PATCH net-next-2.6] net: sock_def_readable() and friends RCU conversion
>
> sk_callback_lock rwlock actually protects sk->sk_sleep pointer, so we
> need two atomic operations (and associated dirtying) per incoming
> packet.
>   

This patch boots for me, I haven't noticed any strangeness yet.

I ran a few benchmarks (the multicast fan-out mcasttest.c
from last year, a few other things we have lying around).
I think I see a modest improvement from this and your other
2 packets. Presumably the big wins are where multiple cores
perform bh for the same socket, that's not the case in
these benchmarks. If it's appropriate:

Tested-by: Brian Bloniarz <bmb@athenacr.com>

> Next one will be able to coalesce wakeup calls (they'll be delayed at
> the end of net_rx_action(), like a patch I did last year to help
> multicast reception)

Keep em coming :)
