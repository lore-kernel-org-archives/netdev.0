From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: move duplicate code from
 tcp_v4_init_sock()/tcp_v6_init_sock()
Date: Thu, 19 Apr 2012 22:21:54 +0200
Message-ID: <1334866914.2395.222.camel@edumazet-glaptop>
References: <1334865321-20288-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>, ilpo.jarvinen@helsinki.fi,
	maze@google.com, Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35081 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473Ab2DSUWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 16:22:03 -0400
Received: by wibhq7 with SMTP id hq7so2164625wib.1
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 13:22:01 -0700 (PDT)
In-Reply-To: <1334865321-20288-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 15:55 -0400, Neal Cardwell wrote:
> This commit moves the (substantial) common code shared between
> tcp_v4_init_sock() and tcp_v6_init_sock() to a new address-family
> independent function, tcp_init_sock().
> 
> Centralizing this functionality should help avoid drift issues,
> e.g. where the IPv4 side is updated without a corresponding update to
> IPv6. There was already some drift: IPv4 initialized snd_cwnd to
> TCP_INIT_CWND, while the IPv6 side was still initializing snd_cwnd to
> 2 (in this case it should not matter, since snd_cwnd is also
> initialized in tcp_init_metrics(), but the general risks and
> maintenance overhead remain).
> 
> When diffing the old and new code, note that new tcp_init_sock()
> function uses the order of steps from the tcp_v4_init_sock()
> implementation (the order is slightly different in
> tcp_v6_init_sock()).
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
