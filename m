From: jamal <hadi@cyberus.ca>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Sat, 4 Jan 2003 13:55:32 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030104134308.G48869@shell.cyberus.ca>
References: <Pine.LNX.4.44.0301041307320.29812-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Greear <greearb@candelatech.com>, Jeff Garzik <jgarzik@pobox.com>,
   "" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
In-Reply-To: <Pine.LNX.4.44.0301041307320.29812-100000@beohost.scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 4 Jan 2003, Donald Becker wrote:

> > > On Fri, 3 Jan 2003, jamal wrote:
> > > > Q: Is this a hack?
> > > > A: Yes, indeed it is. wrong API is the main culprit.
>
> I disagree: it's a hack usable by the very few people that need it.
> Defining an API would add little-used complexity.

Somehow i (and people using VRRP or trying to write HSRP like  apps)
need to have multiple MAC addresses accepted by a single NIC. It is
not really a science project reqnmt, rather needed by real-world apps
which are becoming more common. The way i see it is:"
a) Introduce new API
b) reuse an API - considered a hack really
c) maintain it as a separate patch; needs to be cleaned a little for
optimization (example not all NICS may need this extra per packet check).

Which one do you see as being reasonable?
You cant say none of the above because people need this feature ;->
You have to present an alternative at least.

>
> > Side, unrelated question:
> > for h/ware multicast filtered multicast addresses: What is the common
> > practise to handle the corner case where a hardware multicast address
> > is filled up.
>
> This is good example of why an API is a bad idea: there is no general
> case.  The Tulip has 16 filter addresses, but...
>   Oh, not all chips handled by the Tulip driver.  Macronix does.  Asix
>     doesn't. ADMtek doesn't.  PNIC chips do.

ok.

>   You need one slot for the broadcast address on a few chip versions
>     with a bug.  (I do this unconditionally.)

Make sense.

>   You cannot use the multicast hash filter.

Why not?

>
> "Only in the month after the full moon falls on a Tuesday."
>
> > Take an example of the tulip using perfect hashing when
> > all the 16 entries are exhausted and the host still wants to subscribe
> > to 100 other multicast groups... should we put the nic into promisc
> > multicast?
>
> Yes.  This is the DECnet case.

I dont think this is what we do today in general; does the tulip do this
really?

>
> > didnt know that. I guess i was lucky not to have used the tulip when i
> > got bitten by this. So, Donald, other than tulip what other NICs can do
> > this?
>
> Mostly gigabit Ethernet chips.  There are a few FE chips that allow
> setting the multicast hash address to also filter physical addresses,
> but imperfect filters result in the same extra cdoe as using promiscuous
> mode.
>

OK, i guess this explains the imperfect filters; so since Giges are
becoming such a commodity item, are you suggesting that since to do VRRP
get yourself a Gige card or appropriate FE card?

cheers,
jamal
