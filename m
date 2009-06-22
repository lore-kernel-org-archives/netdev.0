From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] econet: have failed ec_queue_packet() call return
 NET_RX_BAD
Date: Sun, 21 Jun 2009 22:50:18 -0700 (PDT)
Message-ID: <20090621.225018.185805046.davem@davemloft.net>
References: <20090620200438.b5443520.lk-netdev@lk-netdev.nosense.org>
	<20090620105325.GC31266@Chamillionaire.breakpoint.cc>
	<20090620205026.05219c33.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: lk-netdev@lk-netdev.nosense.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43952
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750992AbZFVFuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 01:50:14 -0400
In-Reply-To: <20090620205026.05219c33.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Date: Sat, 20 Jun 2009 20:50:26 +0930

> On Sat, 20 Jun 2009 12:53:25 +0200
> Florian Westphal <fw@strlen.de> wrote:
> 
>> Mark Smith <lk-netdev@lk-netdev.nosense.org> wrote:
>> > econet_rcv() calls ec_queue_packet(). The return from ec_queue_packet()
>> > is the direct result of a call to sock_queue_rcv_skb(). Error returns
>> > from ec_queue_packet() and therefore sock_queue_rcv_skb() are due to
>> > kernel errors, so have econet_rcv() return NET_RX_BAD in this case.
>> 
>> What about doing this instead?
> 
> I think there is value in distinguishing between network/protocol
> errors and kernel errors. It helps determine where the fault might lie
> - in the network somewhere, or isolated to the receiving host. In
> larger organisations there is typically a networks support team and a
> hosts/sys admin team. Hints such as this that help determine who's
> problem the fault is to deal with can be a big time saver (being a
> networking person on one of these sorts of teams, I'm scrathing an
> itch :-) )
> 
> If these econet patches are accepted, I'll send through similar patches
> for the other protocols in the kernel where necessary.

Indeed I bet whoever added NET_RX_BAD thought the distinction had
value too.

But it's been there for many years, and:

1) almost nobody sets it

2) nothing really acts upon or reports it specially

and if after all that time these two things are still true, then
it's obviously worthless in reality.

Therefore my inclination is to apply Florian's patch once the
merge window closes and the next-next-net-2.6 stuff starts getting
applied :-)

You can submit the econet stuff relative to that if you like.  But
I wonder Mark, are you actually using that protocol? :-)


