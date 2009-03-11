From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Wed, 11 Mar 2009 10:11:10 +0100
Message-ID: <49B7802E.2070707@cosmosbay.com>
References: <20090310160040.GA93054@bts.sk>	<20090310.091816.178102814.davem@davemloft.net>	<20090311082920.GA20543@bts.sk> <20090311.014103.163410266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: md@bts.sk, johnwheffner@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43109 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752995AbZCKJLX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 05:11:23 -0400
In-Reply-To: <20090311.014103.163410266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =C3=A9crit :
> From: Marian =C4=8Eurkovi=C4=8D <md@bts.sk>
> Date: Wed, 11 Mar 2009 09:29:20 +0100
>=20
>> For the last time:
>=20
> Thankfully...
>=20
>> setting TCP window to BDP is well-known and generally accepted
>> practice. Autotuning does NOT respect it, and for 100 Mpbs
>> connections at LAN context it might set the rx window somewhere
>> between 100*BDP and 300*BDP. Since the BDP formula obviously applies
>> also in reverse direction, i.e.
>=20
> It's the congestion control algorithm on the sender making this
> happen, not window autosizing.  The window autosizing is only
> providing for flow control.  It's the congestion control algorithm
> that is deciding to send more and more into a path where only
> latency (and not bandwidth) is increasing with larger congestion
> window values.
>=20
> John has tried to explain this to you, and now I have also made an
> effort.  So please stop ignoring what the real issue is here.
>=20
> You also could use Active Queue Management.  But I doubt you would
> bother even testing such a thing to let us know how well that works i=
n
> your situation.  You've already decided how you are willing to handle
> this issue, so it's a fait accompli.
>=20

I am interested to know how use AQM in practice.

Isnt it a matter of :

Using RED on linux hosts, with 'ecn' flag to mark packets instead
 of droping them if possible.

Using ECN enabled clients and servers. (Assuming most trafic is TCP)
Last time I checked, windows XP doesnt have ECN support. Am I wrong ?

Then in the Marian case, it has many senders that might send data to
one target. Active Queue Management wont triger at sender level,
so we need ECN capable routers that are able to use ECN to mark packets=
,
because only these routers will notice a queue congestion ?

Or maybe my focus on ECN is not relevant, since it may be marginal and
only save some percent of bandwidth ?

> It's seems to be not even a matter for discussion for you, so that's
> why this thread will likely go nowhere if it's entirely up to you.
>=20
>> delay=3Dwindow/bandwith
>>
>> setting insanely huge window results in insanely increased LAN laten=
cies
>> (upto buffer limits). Is this really something noone cares about ?!=20
>=20
> Let me clue you in about something you may not be aware of.
>=20
> If you don't auto-tune and let the RX socket buffer increase up
> to a few megabytes, you cannot fully utilize the link on real
> trans-continental connections people are using over the internet
> today.
>=20
> So your suggestion would be a huge step backwards.
>=20
> This is why you keep being told that what you're asking us to do
> is not appropriate.
>=20
> You can't even talk 100Mbit between New York and San Francisco
> without appropriately sized large RX buffers, and RX autotuning
> is the only way to achieve that now.
>=20
> Similarly for west coast US to anywhere in the Asia Pacific region.
>=20
> So the world is much bigger than your little university where you've
> decided to oversubscribe your network, and there are many other issue=
s
> to consider besides your specific localized problem.



