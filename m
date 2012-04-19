From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-next] tcp: move duplicate code from
 tcp_v4_init_sock()/tcp_v6_init_sock()
Date: Thu, 19 Apr 2012 23:39:15 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1204192336140.10089@melkinpaasi.cs.helsinki.fi>
References: <1334865321-20288-1-git-send-email-ncardwell@google.com> <1334866914.2395.222.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	"=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	maze@google.com, Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44901 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932281Ab2DSUjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 16:39:17 -0400
In-Reply-To: <1334866914.2395.222.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Apr 2012, Eric Dumazet wrote:

> On Thu, 2012-04-19 at 15:55 -0400, Neal Cardwell wrote:
> > This commit moves the (substantial) common code shared between
> > tcp_v4_init_sock() and tcp_v6_init_sock() to a new address-family
> > independent function, tcp_init_sock().
> > 
> > Centralizing this functionality should help avoid drift issues,
> > e.g. where the IPv4 side is updated without a corresponding update to
> > IPv6. There was already some drift: IPv4 initialized snd_cwnd to
> > TCP_INIT_CWND, while the IPv6 side was still initializing snd_cwnd to
> > 2 (in this case it should not matter, since snd_cwnd is also
> > initialized in tcp_init_metrics(), but the general risks and
> > maintenance overhead remain).
> > 
> > When diffing the old and new code, note that new tcp_init_sock()
> > function uses the order of steps from the tcp_v4_init_sock()
> > implementation (the order is slightly different in
> > tcp_v6_init_sock()).
> > 
> > Signed-off-by: Neal Cardwell <ncardwell@google.com>
> > ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Btw, there's also tcp_create_openreq_child which duplicates quite much 
init code.

-- 
 i.
