From: Donald Becker <becker@scyld.com>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Sat, 4 Jan 2003 13:24:26 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301041307320.29812-100000@beohost.scyld.com>
References: <20030104122619.R48869@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Greear <greearb@candelatech.com>, Jeff Garzik <jgarzik@pobox.com>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030104122619.R48869@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 4 Jan 2003, jamal wrote:
> On Sat, 4 Jan 2003, Donald Becker wrote:
> > On Fri, 3 Jan 2003, jamal wrote:
> > > Q: Is this a hack?
> > > A: Yes, indeed it is. wrong API is the main culprit.

I disagree: it's a hack usable by the very few people that need it.
Defining an API would add little-used complexity.

> > > How common are NICS such as the 21x4x that can be programmed to do
> > > perfect hashing and accept multiple MAC addresses in hardware?
> >
> > Not very common.  I mentioned the 21*4* explicitly because few other
> > common chips implement this feature.
> > The Digital design implemented it because of DECnet, which is long dead.
> 
> Side, unrelated question:
> for h/ware multicast filtered multicast addresses: What is the common
> practise to handle the corner case where a hardware multicast address
> is filled up.

This is good example of why an API is a bad idea: there is no general
case.  The Tulip has 16 filter addresses, but...
  Oh, not all chips handled by the Tulip driver.  Macronix does.  Asix
    doesn't. ADMtek doesn't.  PNIC chips do.
  You need one slot for the broadcast address on a few chip versions
    with a bug.  (I do this unconditionally.)
  You cannot use the multicast hash filter.

"Only in the month after the full moon falls on a Tuesday."

> Take an example of the tulip using perfect hashing when
> all the 16 entries are exhausted and the host still wants to subscribe
> to 100 other multicast groups... should we put the nic into promisc
> multicast?

Yes.  This is the DECnet case.

> didnt know that. I guess i was lucky not to have used the tulip when i
> got bitten by this. So, Donald, other than tulip what other NICs can do
> this?

Mostly gigabit Ethernet chips.  There are a few FE chips that allow
setting the multicast hash address to also filter physical addresses,
but imperfect filters result in the same extra cdoe as using promiscuous
mode.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
