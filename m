From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: Fri, 16 Jul 2004 19:06:24 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089990384.6114.2842.camel@uganda>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda> <1089906936.6114.904.camel@uganda>
	 <1089908900.1027.77.camel@jzny.localdomain>
	 <1089910757.6114.965.camel@uganda>
	 <1089912658.1029.101.camel@jzny.localdomain>
	 <20040715232035.37e016ef@zanzibar.2ka.mipt.ru>
	 <1089981282.1060.1293.camel@jzny.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-+LSsMhrJDoe8R3omHZBp"
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1089981282.1060.1293.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-+LSsMhrJDoe8R3omHZBp
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2004-07-16 at 16:34, jamal wrote:

> > If I am a master, than get half of bandwidth, but if slave count is
> > less than threshold than get more.
> > If I am a slave and slave count is more than threshold than get
> > 0.5/slave_count of the bandwidth and reserve some else get...
>=20
> Ok, so some controller is in charge - seems like thats something that
> could be easily done in user space based on mastership transitions.

Yes, but here is tricky but true example:
Some time ago e1000 driver from Intel had possibility to do hardware
bonding(i absolutely don't remember how it was called, but idea was the
same as in bonding).
Consider following scenario: if node is a master than it enables this
bonding mode using e1000 internal registers. Ethtools doesn't support
those mode. yes it also can be enabled through patching userspace, but
with kernel CARP it is not needed.
Or consider TGE example(...wireless HA... strange sentence, but...):
If I am a master, than enable higher priority in driver.
Current tc design can't be mapped to driver's internal structures :>

But the main killer is following:
consider firewall with thousands iptables rules, and if node becomes a
master it needs to add or remove some rules from table.
Copying such amounts to/from userspace/kernelspace memory will take
_minutes_... Even using iptables chains.
But kernel implementation may just add one rule.

Yet another variant: you need to access CPU internal registers based on
HA state, kind of turning on or off additional hotplug CPU and or
memory, enabling/disabling NUMA access. Can you enable/disable bus
arbiter from userspace?
For example I'm using on-chip SDRAM in PPC440 as L2 cache or as jitter
buffer for OPB access, decision to use each mode is based on some
hardware loads. Userspace do not have access to such mechanism.
It is deep kernel internals, and I do not see any good reason to export
it to userspace.
Actually last example can't be used as argument in our discussion, but
it illustrates that sometimes we need to touch kernel-_only_ parts, and
this decision is dictated from the outside of the touchable part.


> > What about case when you do need kernel space access based on CARP
> > state?
>=20
> What kind of access? To configure something? what kind of thing?

Some kind of scenarios above?

> > It is case of abstraction: for some reason(and for most of all) you do
> > not need kernel space implementation.
> > But reasons do exist to use it in kernel space, and if it will become a=
n
> > issue some day, you will anyway create a kernel agent. If you need
> > kernel access in HA system, do not create new agents, just use CARP as
> > kernel agent and arbiter.
>=20
> Iam not buying it Evgeniy, sorry ;->

I see :)

> BTW, I like that ARP balancing feature that CARP has. Pretty neat.
> Note that it could be easily done via a tc action with user space
> control.

Anything may be done in userspace.
For example routing decision.
Yes, it _may_ be done in userspace. But it is slow.
SCSI over IP may be done as network block device.
Or even copying packet to userspace through raw device and then send it
using socket.
QNX and Mach are even designed in this way.

It is not talk about current possibilities, it is kind of design :)
Yes, probably our _current_ needs may be satisfied using existing
userspace tools.
But I absolutely sure that we will need in-kernel support.
I'm reading you second e-mail with pretty diagrams and already see where
in-kernel CARP will live there :)

> cheers,
> jamal
--=20
	Evgeniy Polaykov ( s0mbre )

Crash is better than data corruption. -- Art Grabowski

--=-+LSsMhrJDoe8R3omHZBp
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBA9+7wIKTPhE+8wY0RArRVAJwOr1JqADlAw1lo2DuL1NRQvGx2pQCgl/k7
Hy3KqUN5YH3FruhYjvXtqNY=
=Drpx
-----END PGP SIGNATURE-----

--=-+LSsMhrJDoe8R3omHZBp--
