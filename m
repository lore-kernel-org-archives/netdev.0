From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: move duplicate code from
 tcp_v4_init_sock()/tcp_v6_init_sock()
Date: Sat, 21 Apr 2012 16:31:48 -0400 (EDT)
Message-ID: <20120421.163148.936993860405268213.davem@davemloft.net>
References: <1334865321-20288-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, nanditad@google.com,
	ycheng@google.com, ilpo.jarvinen@helsinki.fi, maze@google.com,
	therbert@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab2DUUcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 16:32:01 -0400
In-Reply-To: <1334865321-20288-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 19 Apr 2012 15:55:21 -0400

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

Applied.
