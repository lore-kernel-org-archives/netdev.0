From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: Thu, 15 Jul 2004 20:59:20 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089910760.6114.967.camel@uganda>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda>
	 <1089907622.1027.48.camel@jzny.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-w23J5Lt4NFSmfeMPtgq1"
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1089907622.1027.48.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-w23J5Lt4NFSmfeMPtgq1
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2004-07-15 at 20:07, jamal wrote:

> > > Why do you need to put this stuff in the kernel?
> > > This should be implemented just the same way as VRRP was - in user
> > > space.
> >=20
> > Hmm...
> > Just because i think it works better being implemented in the kernel? :=
)
> > I don't think it is a good answer thought.
> >=20
> > It is faster, it is more flexible, it has access to kernel space...
>=20
> Yeah, I know ;-> and probably thats what the opnebsd people did.
> =20
> I still think it should live in user space.  This should apply to
> anything thats control related because such things tend to be
> continoulsy enrichned with features. ARP unfortunately is in there; one
> of my pet perpetual projects is to totaly rip it off. Theres already
> hooks to deliver to user space today and Alexey has a daemon for it, not
> sure how widely used it is.

Userspace is too slow.
It can only initiate master's failover, load balancing is a good example
here - userspace _itself_ can not control real time traffic.

> > > BTW, is there a spec for this protocol or its one of those things whe=
re
> > > you have to follow Yodas advice?
> >=20
> > Exactly :)
> > Here are all links I found:
>=20
> Thank you.=20
> I think a better idea would be to implement a sync message
> within CARP instead of that pfsync app doing its own thing. Unless i
> misread, pfsync seems to be a separate app.
> This way more than one app can use it via the CARP daemon
> in user space to sync state of their choice (with whatever pfsync does
> being one of many).=20

ct_sync module does this.
It uses connection tracking and sends firewall state across slaves.
CARP is separate by design - anyone may "attach" to master/slave
failover.

> This is an example of a rich application and further justification for
> it to live in user space.

If it will live in userspace, it just can not control realtime traffic
and even provide some mechanism to achive this.

> > I do want this to be in the mainline kernel, but actually I even don't
> > think anyone will apply it.
> >
> > It is too special stuff for generic kernel, it has reserved 112 vrrp
> > protocol number and so on...
> > So if developers decide not to include or even not to discuss this cruf=
t
> > I will not beat myself by my heels. :)
> >=20
> > It just works as expected, it is reliable and simple.
> > And it does it's work, so HA people would like it.
>=20
> It is valuable, just doesnt belong to the kernel.
> BTW, i saw some claim that this is patent-free as opposed to VRRP?
> I do hope it takes off.  What exactly is the patent issue that was at
> stake? I couldnt tell from the song lyrics ;->

:) Cisco + hsrp =3D=3D vrrp, but the former is patented.
Here is quote from Ryan McBride, an author of the CARP:

* P.S. If anyone has concerns about the Cisco's patent #5,473,599 and
how their claim that it applies to VRRP has forced us to design our own
incompatible protocol, don't talk to us. Instead, call Cisco's lawyer at
408-525-9706, or email him: rbarr@cisco.com *


> One valuable thing that could be done is while still avoiding any patent
> issues make it interop with VRRP.

VRRP is not secure, it is protocol dependent, it is not free...

> cheers,
> jamal
--=20
	Evgeniy Polaykov ( s0mbre )

Crash is better than data corruption. -- Art Grabowski

--=-w23J5Lt4NFSmfeMPtgq1
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBA9rfoIKTPhE+8wY0RAsynAJ4+N5RgnU/AbDlFcyjE9QILiEloEwCeIgGG
rQgVt4D/k+RKRVIwsRDcm14=
=Mh7g
-----END PGP SIGNATURE-----

--=-w23J5Lt4NFSmfeMPtgq1--
