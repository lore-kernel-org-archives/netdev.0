From: James Carlson <carlson@workingcode.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Fri, 27 Jun 2003 07:39:19 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16124.11495.374998.153330@h006008986325.ne.client2.attbi.com>
References: <20030625.143334.85380461.davem@redhat.com>
	<20030626035824.D68B62C147@lists.samba.org>
	<20030625.205941.41631020.davem@redhat.com>
	<16122.53298.150512.793074@h006008986325.ne.client2.attbi.com>
	<20030626190407.S87648@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, rusty@rustcorp.com.au,
   paulus@samba.org, netdev@oss.sgi.com, fcusack@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: Jamal Hadi's message of 26 June 2003 19:18:20
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal Hadi writes:
> So what about packet being loss? Wouldnt that ensure reordering?

Please explain.  What pattern of loss possibly results in one packet
being inserted in the stream ahead of another?

Here's loss:		1 2 4 5 6

Here's reordering:	1 2 4 3 5 6

Loss preserves ordering.  To get misordering, you have to
intentionally hold onto a message and reinsert it later.  What I've
been pointing out is that the 802 MAC layer *does not* permit
misordering (or duplication, for that matter).  Loss, reordering, and
duplication are all separate errors.

> And there is no such thing as a lossless wire.

True, but not relevant.  When you put packets onto a wire, you must do
so in a particular order -- it's not possible to put more than one
packet at a given time on a single wire.  It's also not possible for
the receiver to get them in a different order than you sent them.
They're essentially "single file" on that wire.

PPP relies on this fact (albeit for serial wires) as part of its
protocol definition (RFC 1661):

1.  Introduction

   The Point-to-Point Protocol is designed for simple links which
   transport packets between two peers.  These links provide full-duplex
   simultaneous bi-directional operation, and are assumed to deliver
   packets in order.  It is intended that PPP provide a common solution
[...]

In addition, the 802 MAC layer cannot reorder packets, so there is no
conflict here.  Although there are many design mistakes in PPPoE, this
just is not one of them.

There is a design problem here, but it's not PPPoE's.

> PS:- Paulus i wasnt preaching getting rid of ppp/pppoe although its
> a nice thouhgt. More fix linux pppd and pppoe ;->

Believe me, the IETF working group didn't want PPPoE, either.  It
dropped from outer space.  The only reason it was published as
"Informational" is that it had already been deployed (before anyone
bothered to talk to the folks who are responsible for the PPP
standards), and thus somebody might want to know about it.

If we could have killed it, we would have.

-- 
James Carlson                                  <carlson@workingcode.com>
