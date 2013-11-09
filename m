From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netlink: fix netlink_ack with large messages
Date: Sat, 9 Nov 2013 20:49:02 +0100
Message-ID: <20131109194902.GA4732@localhost>
References: <20131109000434.GD28793@casper.infradead.org>
 <20131109.000012.1393414533296613338.davem@davemloft.net>
 <527E3C17.1080508@mojatatu.com>
 <20131109.142706.307323939750387593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, tgraf@suug.ch, jbenc@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43371 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756302Ab3KITtH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Nov 2013 14:49:07 -0500
Content-Disposition: inline
In-Reply-To: <20131109.142706.307323939750387593.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 09, 2013 at 02:27:06PM -0500, David Miller wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> Date: Sat, 09 Nov 2013 08:43:51 -0500
> 
> > for errors, we need to give the user something back. This has been the
> > behavior for 80 years now. Giving them a HUGE message
> > back is rediculuos(tm). Ive had enough of SCTP doing that.
> > We need to cap it - sort of what ICMP does.
> > ICMP caps at 64B; something like 128B is reasonable.
> 
> It is correct that we really can't change existing behavior.
> 
> I want to do something smarter in the new cases where we can.
> 
> nftables is the first thing that works with such enormous
> messages, so let's create a facility such that nftables
> netlink users don't need to get the entire quote message
> back.
>
> That's why I suggested a per-subsystem flag, that entities like
> nftables can set when it registers, that says "don't quote the message
> in the ACK."
> 
> Or, alternatively, let's have the application set this flag,
> via a socket option or similar.
> 
> Both approaches work for me, and the latter probably gains us
> the most over time as we can make sure that eventually all the
> major netlink apps start setting the flag.

In the nftables case, we send a large packet containing small netlink
messages, so it's unlikely that we'll hit the problem that Jiri
reported since the ack is reported back per small message in the
packet.

But we still have to fix this for other netlink subsystems following
either approach, David's flag or Jamal's netlink error with origin
netlink message cap.
