From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: fix netlink_ack with large messages
Date: Sat, 09 Nov 2013 14:27:06 -0500 (EST)
Message-ID: <20131109.142706.307323939750387593.davem@davemloft.net>
References: <20131109000434.GD28793@casper.infradead.org>
	<20131109.000012.1393414533296613338.davem@davemloft.net>
	<527E3C17.1080508@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, jbenc@redhat.com, netdev@vger.kernel.org,
	pablo@netfilter.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44093 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756302Ab3KIT1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 14:27:11 -0500
In-Reply-To: <527E3C17.1080508@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sat, 09 Nov 2013 08:43:51 -0500

> for errors, we need to give the user something back. This has been the
> behavior for 80 years now. Giving them a HUGE message
> back is rediculuos(tm). Ive had enough of SCTP doing that.
> We need to cap it - sort of what ICMP does.
> ICMP caps at 64B; something like 128B is reasonable.

It is correct that we really can't change existing behavior.

I want to do something smarter in the new cases where we can.

nftables is the first thing that works with such enormous
messages, so let's create a facility such that nftables
netlink users don't need to get the entire quote message
back.

That's why I suggested a per-subsystem flag, that entities like
nftables can set when it registers, that says "don't quote the message
in the ACK."

Or, alternatively, let's have the application set this flag,
via a socket option or similar.

Both approaches work for me, and the latter probably gains us
the most over time as we can make sure that eventually all the
major netlink apps start setting the flag.
