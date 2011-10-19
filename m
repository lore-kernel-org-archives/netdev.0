From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga)
 causes kernel oops
Date: Wed, 19 Oct 2011 04:02:40 -0400 (EDT)
Message-ID: <20111019.040240.758852119107748001.davem@davemloft.net>
References: <1319008713.17914.8.camel@edumazet-laptop>
	<20111019.033052.851679720607111734.davem@davemloft.net>
	<1319010739.18562.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, evonlanthen@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319010739.18562.6.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Oct 2011 09:52:19 +0200

> For GRE tunnels, I dont think IPv6 fragmentation could be relevant,
> but maybe IGMP could trigger a problem ?

Funny... icmpv6 uses ip6_append_data() which uses hh_len in a
local variable, which seems to suggest that it's immune to
this problem.

IPV4 side seems identical in this regard.

So, as far as I can see, my patch is sufficient to cover IP_GRE
reasonably in the 'net' tree.

Agreed?

If so, someone please test this thing :-)
