From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Device operative state notification against 2.5.7
Date: Mon, 1 Apr 2002 22:05:15 -0500 (EST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204012136250.14729-100000@shell.cyberus.ca>
References: <080d01c1d9bc$3d4510a0$6800000a@brownell.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stefan Rompf <srompf@isg.de>, <netdev@oss.sgi.com>
To: David Brownell <david-b@pacbell.net>
In-Reply-To: <080d01c1d9bc$3d4510a0$6800000a@brownell.org>
List-Id: netdev.vger.kernel.org



On Mon, 1 Apr 2002, David Brownell wrote:

> Two comments on this stuff:
>
> (A) I skimmed the 3.1.13 descriptions in RFC 2863.
> If RUNNING is to correspond to ifAdminStatus,
> and NO_CARRIER is inverted up/down ifOperStatus,
> this starts to make sense.  For example, it defines
> the set/set state in Jamal's table as a fault condition.

Actually ifOperStatus == NO_CARRIER/IFF_RUNNING set
NO_CARRIER is used to reflect IFF_RUNNING in serialized way.
ifAdminStatus == IFF_UP
Someone needs to enumarate a different truth table with IFF_UP etc
based on the RFC.

>
> That doesn't quite seem like a complete match though,
> and not only because one can't map N-ary ifOperStatus
> (up, down, unknown, testing, dormant, notPresent, and
> maybe more) to single bits like NO_CARRIER.
>

I think we need three bits now to represent IFF_RUNNING (as opposed to the
old 1 bit); we also need two bits for IFF_UP; note both are defined as
integeers. My only concern is how to map NO_CARRIER now that we have
this.


> (B) In Jamal's table I'm thinking about how IP-over-USB
> stacks would work.  Those tend to be point-to-point
> links with Ethernet framing (easier to bridge :).

That table is now inappropriate; we need a new one to map
IFF_UP and the two bits in IFF_RUNNING.

>
> The devices themselves are all hotplugged, so their
> interface names won't exist unless there's hardware
> (maybe it's in the process of being unplugged).  But
> that means there are three meaningful modes:
>
>     - Only "my" end connected ... nobody on the
>       other end (treated as NO_CARRIER) so
>       IFF_RUNNING can't _ever_ usefully be set
>

	!IFF_UP and IFF_RUNNING == dormant

but once USB negotiation starts IFF_RUNNING  should transition to
notPresent
BTW, i think that IFF_RUNNING == notPresent should also apply for
ethernet where theres MII autonegotiation failures (speed mismatch)

>     - Both ends connected (!NO_CARRIER)
>       so IFF_RUNNING could be set or not.
>

        !IFF_UP and IFF_RUNNING == up

>     - "Indeterminate" ... some cables might not be
>       able to report whether someone's on the other
>       end.  Driver would necessarily treat as if both
>       ends were always connected.

I guess one of those other oper states would represent things
Admin status could be up/down.

IFF_UP goes to up only if an IP address has been assigned to
the USB interface for example via DHCP etc
I am kind of brain dead right now, but i am sure we can
map hotplug devices easily

cheers,
jamal
