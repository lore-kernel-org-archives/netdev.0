From: jamal <hadi@cyberus.ca>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Sat, 4 Jan 2003 12:41:23 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030104122619.R48869@shell.cyberus.ca>
References: <Pine.LNX.4.44.0301040121530.29812-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Greear <greearb@candelatech.com>, Jeff Garzik <jgarzik@pobox.com>,
   "" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
In-Reply-To: <Pine.LNX.4.44.0301040121530.29812-100000@beohost.scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 4 Jan 2003, Donald Becker wrote:

> On Fri, 3 Jan 2003, jamal wrote:
>
> > Too many emails to respond to at once.
> >
> > Q: Is this a hack?
> > A: Yes, indeed it is. wrong API is the main culprit.
> >
> > Q: Is this a feature needed by only a few people?
> > A: No, Absolutely not. RFC2338 is one example that needs
>
> The common way of handling this is unsolicited ARP.
>

unsolicited ARPs on failover are good. You send the arp with
one of the allocated MAC addresses as the source. The hosts
sending data use that MAC address as the dst MAC. Did i miss something
or how do you see the packet making its way up the stack?

> > How common are NICS such as the 21x4x that can be programmed to do
> > perfect hashing and accept multiple MAC addresses in hardware?
>
> Not very common.  I mentioned the 21*4* explicitly because few other
> common chips implement this feature.
> The Digital design implemented it because of DECnet, which is long dead.
>

Side, unrelated question:
for h/ware multicast filtered multicast addresses: What is the common
practise to handle the corner case where a hardware multicast address
is filled up. Take an example of the tulip using perfect hashing when
all the 16 entries are exhausted and the host still wants to subscribe
to 100 other multicast groups... should we put the nic into promisc
multicast?

> > And if this was a commodity feature - what happens to PACKET_HOST
> > setting? an netdevice can only have one unicast MAC address.
> > SIOCDEVPRIVATE does not seem to be the right place to do this.
> > You still wanna have ability to do proper RFC2338 and related protocols
> > even when the h/ware is incapable.
> > And btw, i didnt even open up the whole can of worms - we also need to
> > respond back with proper MAC addresses to ARPs and packets sourced with
> > specific virtual router IPs. This is a seprate problem.
>
> Yup, a whole can of worms if you want it to be a general feature handled
> by the kernel...
>

I think hacking the ARP code to do this would be horrible - one way to do
it is write a tc module that mungles outgoing ARPs to substitute the src
MAC address based on src IP.

> > PS: the hack credit (for using SIOCADDMULTI/DELMULTI) goes to Jerome
> > Ettiene (this is a guy who never responds to email, probably too busy
> > unicycling somewhere, so no point in ccing him) - Except it doesnt work
> > without the patch i posted.
>
> This has worked with the Tulip driver for many years.  I've pointed it
> out to a number of people that requested this as a new feature.
>

didnt know that. I guess i was lucky not to have used the tulip when i
got bitten by this. So, Donald, other than tulip what other NICs can do
this?

cheers,
jamal
