From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v6 4/7 RFC] TCPCT part 1d: define TCP
 cookie option, extend existing struct's
Date: Tue, 17 Nov 2009 04:22:50 -0800 (PST)
Message-ID: <20091117.042250.28821014.davem@davemloft.net>
References: <4B01D17C.4010407@gmail.com>
	<20091116.191522.178198674.davem@davemloft.net>
	<alpine.DEB.2.00.0911171412380.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, william.allen.simpson@gmail.com,
	netdev@vger.kernel.org, joe@perches.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51581
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755069AbZKQMWe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 07:22:34 -0500
In-Reply-To: <alpine.DEB.2.00.0911171412380.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 17 Nov 2009 14:18:57 +0200 (EET)

> On Mon, 16 Nov 2009, David Miller wrote:
>=20
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Mon, 16 Nov 2009 23:26:04 +0100
>>=20
>> > So adding DATA to SYN packets might be problematic for part of our=
 tcp=20
>> > stack.=20
>>=20
>> I can almost guarentee it won't work.  For one thing getting a SACK
>> response to a SYN+DATA packet will explode quite nicely for one thin=
g.
>=20
> Now I'm really lost??? How can you get SACKs for that in the first=20
> place since they are either lost or delivered in unison???

Ideally, you're probably right.

However, it seems to me that the receiver can do whatever it likes
with it's receive queue when it's under memory pressure.

It can chop packets up, partially free bits, and then send a SACK
block back to you for the parts it tried to free.

If you'll recall, I wanted to put some tough restrictions into what is
allowed with SACK so that we could optimize things on the sender side.
But there was resistence and therefore we have to keep allowing all
kinds of silly situations, the one we're talking about here merely
being one of them :-)
