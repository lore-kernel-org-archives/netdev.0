From: Stephen Frost <sfrost@snowman.net>
Subject: Re: [IPSEC] Too many SADs!
Date: Mon, 28 Mar 2005 08:33:10 -0500
Message-ID: <20050328133310.GM8725@ns.snowman.net>
References: <200503220052.52756.wolfgang.walter@studentenwerk.mhn.de> <20050322224819.GB4924@questra.com> <20050323003310.GE8725@ns.snowman.net> <20050323055520.GH13092@questra.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gmhhrsDozM2n+uz5"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Mcdermott <smcdermott@questra.com>
Content-Disposition: inline
In-Reply-To: <20050323055520.GH13092@questra.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--gmhhrsDozM2n+uz5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* Scott Mcdermott (smcdermott@questra.com) wrote:
> Stephen Frost on Tue 22/03 19:33 -0500:
> > Sounds like I may need to check out strongswan/openswan.
> > I can tell you I wasn't exactly a fan of freeswan for a
> > variety of reasons.
>=20
> What reasons? The userspace code with it is great (i.e. the
> IKE daemon).  The kernel stuff may be a different matter.
> You could use the native IPSEC code in the kernel instead.

With freeswan it was: kernel code sucking, difficulty getting
it going, the attitude of upstream esp wrt contributions from
people in the US (sorry, but that's where I am and I don't
plan on moving), and the evil configuration syntax which I
detest.

strongswan/openswan appears to have fixed at least some of
these issues (don't need to patch the kernel and so no KLIPS,
apparently better attitude and maybe not so hard to get it
going) but the evil configuration syntax is still there though
more hacked up to support the newer options which doesn't seem
to have done much for its looks.

I'm now currently concerned about a few things w/
strongswan/openswan: policy definitions given to the kernel by
*swan instead of more directly by me, transport/require ipsec
(esp. to a /24 or similar), AES crashing openswan in its latest
release, 2.6.11 'fwd' kernel policy support (is it there?),
and support for 'default route' tunnels (ie: tunnel from me
out my gw to the rest of the world- I want it encrypted from
me to my gw where it can possible be reencrypted to go out
another tunnel or decrypted and sent in the clear across the
net when ipsec isn't required).

I've also got concerns about the kernel-level stuff that's
independent of IKE: IPSEC and Netfilter interaction (or lack
thereof, though I'm using Patrick's patches now which do
help with that some) esp. wrt filtering, SNAT and DNAT,
IPSEC and routing (esp. wrt multiple ipsec tunnels on a
machine and passing packets w/ the whole decrypt - netfilter
- reencrypt for new tunnel bit), libpcap interaction with
IPSEC transport which doesn't seem to work so hot (it seems
that the IPSEC header has been 0'd out in the packet but
it's still there and libpcap thinks that's the body of the
packet and it can't know any different), and MTU issues
though so far these havn't given me *too* much trouble.

Sorry but I really just can't stand the *swan configuration
syntax. :)  I guess I'll have to give it a shot and possibly
live with it if it works so much better but the whole
left/right/middle/top/bottom/whatever bit just annoys the
hell out of me. :)

> I don't know what distribution you're using but I found it
> simple to adapt the openswan .spec file to make a source RPM
> for strongswan.

Debian/sid.  OpenSwan appears to be in sid w/ version 2.3.0
but I don't see StrongSwan.  Probably wouldn't be too hard
to adopt the OpenSwan deb stuff to StrongSwan and if it turns
out to work so well perhaps I'll upload it to the archive
(I'm a DD and stuff).

> As I understand it, the Openswan project is motivated by
> commercial interests, whereas Strongswan is in it for
> security and correctness.  I had difficulty using Openswan

Being in it for the money can have its advantages, like
people on staff paid full time to work on improving it. :)

> with AES (it wasn't accepting custom ciphers and DH groups
> specified in the config file, and was sending bogus IKE
> proposals with 65535 in all the fields of the first listed
> transform) until I switched to Strongswan.  And if you are
> doing anything with X.509, the author of that patch is the
> one that forked Strongswan.  It has been very solid for me
> since I switched off Racoon.

This is certainly one of my concerns- I'm currently intending
to use AES as much as possible (des3 for some Windows hosts)
and I noticed that the OpenSwan page says 2.3.1 has problems
with it.  Sounds like StrongSwan doesn't have this problem?
Given the similar codebase (at least, I thought they were
similar, perhaps they aren't?) how is it that it works for
one and not the other?

We're certainly using X.509 certs a fair bit and have some
rather serious security dependencies on those certs.  The
StrongSwan/OpenSwan configuration appears to better support
identification-by-certificate than Racoon did (as far as I
could tell anyway) though its requirements wrt what happens
if you want to use subjectAltName seemed a bit odd and may
pose a problem, though I'm hoping to be able to use the DN
for identification but I'm not the CA for these certs so
I'm not 100% sure what the best identifying attribute will
be for me.

Thanks for the comments and concern.  I'd be happy to hear
=66rom others on any of my comments/concerns from above.  Just
looking for the best solution for my requirements.

	Stephen

--gmhhrsDozM2n+uz5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFCSAeVrzgMPqB3kigRAi6GAJ9mZ9pH7TJjCq0XSw2PbYb1AANkXQCgjFps
xiMkrviHz2fnl/fvcnkbTzY=
=ANZB
-----END PGP SIGNATURE-----

--gmhhrsDozM2n+uz5--
