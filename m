From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NIU support for skb->rxhash
Date: Fri, 23 Apr 2010 13:28:01 -0700 (PDT)
Message-ID: <20100423.132801.192648533.davem@davemloft.net>
References: <20100422.141922.39169749.davem@davemloft.net>
	<20100423.011456.48472321.davem@davemloft.net>
	<h2z65634d661004230832o4f7a6d35ub207bc301ee8925c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36687
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754517Ab0DWU14 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Apr 2010 16:27:56 -0400
In-Reply-To: <h2z65634d661004230832o4f7a6d35ub207bc301ee8925c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Tom Herbert <therbert@google.com>
Date: Fri, 23 Apr 2010 08:32:02 -0700

>> I looked into implementing this and it doesn't work. =A0The
>> problem is GRO want's to look into the packet very early
>> and we want to batch GRO a set of packets into a big packet
>> before shooting them over to a remote cpu.
>>
>=20
> Can you reconsider? :-)  The majority of our servers see packet loads
> which don't allow for much batching (a lot of small RPC messages), so
> for those GRO is mostly unnecessary overhead and mechanisms that
> improve unbatched packet performance are compelling.  Also, if a
> device already does LRO, I don't see that GRO could add a lot of valu=
e
> anyway.

LRO is extremely discouraged, because it has to be disabled
when any form of forwarding or bridging is enabled.  LRO is
done such that the input packet stream cannot be reconstituted
on transmit.

GRO on the other hand, allows proper reconstitution of the input
packet stream so it can be enabled unconditionally.

We are encouraging hardware manufacturers to tweak their receive
batching offload such that it matches the rules imposed by GRO
which allow proper reconsitution on transmit.

The fact is the code patch is there and it is going to be enabled all
the time, so we have to cope with it.

