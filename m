From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Wed, 25 Nov 2015 11:38:14 +0100
Message-ID: <1448447894.488780.449645185.04F14CE4@webmail.messagingengine.com>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
 <20151123.145433.1554000376541433305.davem@davemloft.net>
 <20151124152744.GB20972@breakpoint.cc>
 <20151124.105537.185897620062606312.davem@davemloft.net>
 <20151124162515.GA22266@breakpoint.cc>
 <1448389410.599529.449007361.7A816A14@webmail.messagingengine.com>
 <20151124185942.GA73070@ast-mbp.thefacebook.com>
 <1448392585.611746.449059097.46CE87C0@webmail.messagingengine.com>
 <20151124202340.GA78406@ast-mbp.thefacebook.com>
 <1448402288.1489559.449199721.64EBB346@webmail.messagingengine.com>
 <20151124222109.GA86838@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tom Herbert <tom@herbertland.com>,
	Florian Westphal <fw@strlen.de>, davem@davemloft.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:34459 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751982AbbKYKiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 05:38:15 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id A6B6120309
	for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 05:38:14 -0500 (EST)
In-Reply-To: <20151124222109.GA86838@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Nov 24, 2015, at 23:21, Alexei Starovoitov wrote:
> On Tue, Nov 24, 2015 at 10:58:08PM +0100, Hannes Frederic Sowa wrote:
> > > > > 
> > > > > interesting idea, but then remote host will be influencing local cpu
> > > > > selection?
> > > > > how remote can figure out the number of local cpus?
> > > > 
> > > > Via rpc! :)
> > > > 
> > > > The configuration shouldn't change all the time and some get_info rpc
> > > > call could provide info for the topology of the machine, or...
> > > 
> > > Configuration changes all the time. Machines crash, traffic redirected
> > > because of load, etc, etc
> > 
> > Yeah, same problem you have to handle with the kcm approach.
> 
> not at all. No new remote configuration things are needed.

At some point you have to manage your ip address and if you move a host
subnet or an ip address it should not matter a lot.

> > Just use GRO engine and TCP PSH flag, maybe by making it more
> > intentional via user space APIs on one connection. Wake up thread with
> > one complete RPC message. If receiver eats more data it is no problem,
> > if less, it will block as in your approach, too. Your worker threads
> > must handle that anyway and can buffer and concatenate it to the next
> > message to be processed.
> 
> of course not. kcm reading threads don't have to deal with it.

If there is no fallback for this you have to drop frames and kill the
TCP connection for all your RPC endpoints. If you lost synchronization
with the headers there is no way you will resync. 

> PS
> just noticed that you've excluded all. By accident?
> Feel free to reply to all.

Oh, thanks, yes it was a fault on my side.

For full transparency I reply.

Bye,
Hannes
