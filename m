From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] [next-next-2.6] net: configurable device name hash
Date: Thu, 12 Nov 2009 15:09:57 +0100
Message-ID: <4AFC1735.6000105@gmail.com>
References: <20091111.124235.243348591.davem@davemloft.net>	<20091111133342.1011e16a@nehalam>	<200911112347.41425.opurdila@ixiacom.com>	<20091111.183626.202530131.davem@davemloft.net> <20091112231620.0b56c0b0@opy.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, opurdila@ixiacom.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37573 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199AbZKLOKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 09:10:06 -0500
In-Reply-To: <20091112231620.0b56c0b0@opy.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Smith a =E9crit :
> On Wed, 11 Nov 2009 18:36:26 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
>=20
>> From: Octavian Purdila <opurdila@ixiacom.com>
>> Date: Wed, 11 Nov 2009 23:47:41 +0200
>>
>>> We could use a similar function that will work in the per namespace
>>> initialization context, but this might upset net namespace folks
>>> since we will get a large hash for every namespace.
>> Use kzalloc(), that's sufficient for a 64K or so hash table which is
>> way more than you ever will need.
>>
>> Use the GFP_* flags that will silently (ie. without a log message)
>> fail, and divide by two until you successfully allocate the table if
>> you're worried about memory fragmentation at allocation time.
>>
>> This is so straightforward, I can't believe we're talking so much
>> about how to implement this, it's a 15 minute hack :-)
>=20
> Yes, but sadly, sometimes there is too much history(!) to be able to =
be
> fully aware of it. "suck-it-and-see" type patches are possibly a
> quicker way to find out what people are thinking right now!
>=20

Before extending hash tables, we should make sure existing algos are go=
ing to
scale with millions of netdevices, and they dont scale that much for th=
e moment.
We still have many for_each_netdev() loops...

It's easy to change a constant somewhere in an include file, its less e=
asy to make
real scalability changes :(

