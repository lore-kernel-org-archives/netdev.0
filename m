From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [PATCH] econet: have failed ec_queue_packet() call return
 NET_RX_BAD
Date: Sat, 20 Jun 2009 20:50:26 +0930
Message-ID: <20090620205026.05219c33.lk-netdev@lk-netdev.nosense.org>
References: <20090620200438.b5443520.lk-netdev@lk-netdev.nosense.org>
	<20090620105325.GC31266@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:54021 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbZFTLUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 07:20:31 -0400
In-Reply-To: <20090620105325.GC31266@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Sat, 20 Jun 2009 12:53:25 +0200
Florian Westphal <fw@strlen.de> wrote:

> Mark Smith <lk-netdev@lk-netdev.nosense.org> wrote:
> > econet_rcv() calls ec_queue_packet(). The return from ec_queue_packet()
> > is the direct result of a call to sock_queue_rcv_skb(). Error returns
> > from ec_queue_packet() and therefore sock_queue_rcv_skb() are due to
> > kernel errors, so have econet_rcv() return NET_RX_BAD in this case.
> 
> What about doing this instead?
> 

I think there is value in distinguishing between network/protocol
errors and kernel errors. It helps determine where the fault might lie
- in the network somewhere, or isolated to the receiving host. In
larger organisations there is typically a networks support team and a
hosts/sys admin team. Hints such as this that help determine who's
problem the fault is to deal with can be a big time saver (being a
networking person on one of these sorts of teams, I'm scrathing an
itch :-) )

If these econet patches are accepted, I'll send through similar patches
for the other protocols in the kernel where necessary.

Thanks,
Mark.
