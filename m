From: Harald Welte <laforge@netfilter.org>
Subject: Re: NAT before IPsec with 2.6
Date: Wed, 28 Jan 2004 14:00:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128130050.GS11761@sunbeam.de.gnumonks.org>
References: <20040124082252.GA19035@alpha.home.local> <Pine.LNX.4.44.0401241015470.32723-100000@filer.marasystems.com> <20040124092721.GA19140@alpha.home.local> <20040127103917.GC11761@sunbeam.de.gnumonks.org> <20040127132725.GA14685@openoffice.nl> <pan.2004.01.27.21.13.32.754125@dungeon.inka.de> <20040128085831.GM11761@sunbeam.de.gnumonks.org> <1075285293.5055.29.camel@simulacron>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GdipSGKQZT5VYjAa"
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Jellinghaus <aj@dungeon.inka.de>
Content-Disposition: inline
In-Reply-To: <1075285293.5055.29.camel@simulacron>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--GdipSGKQZT5VYjAa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 28, 2004 at 11:21:34AM +0100, Andreas Jellinghaus wrote:
> On Wed, 2004-01-28 at 09:58, Harald Welte wrote:
> > However, it doesn't reset the skb->nfct pointer,
>=20
> the tunnels do.=20

yes, I'm well aware of that.

> In summary it looks to me, like you want to have everything that a
> real tunnel with an interface offers, but for some reason you don't
> want the tunnel with the interface. right?
> so, why?

Because it's needed for interoperability with other IPsec
implementations, in other words if you are not running Linux on both
ends.  Yes, I know... in an ideal world everybody would run linux on
both ends... but if you do: Why use IPsec at all, if not for
interoperability.

> > - no working connection tracking in any kind of ipsec scenario

s/ipsec scen/plain non-tunnel ipsec scen/

> > Did anybody propose ugly hacks in the routing table?
>
> if you don't use an interface, you need them in real world setups.

oh well, what you are describing are entries in the routing table,
that's fine.  I thought you were talking about hacking the routing code.

> and swithcing from wlan0 to eth0 does not only require
> the tunnel to be reconfigured (local and remote ip), but
> also changes in the routing table. that is horrible.

well, this is just like the 2.6.x ipsec implementation is like.  It's
not the netfilter project's will or task to change that implementation.
We just want to get the same netfilter/iptables functionality,
independent of somebody using ipsec or not.

> > So we absolutely _need_ a symmetric-to-incoming behaviour like:
>=20
> use an tunnel interface and you have that.

yes, but as stated above, other implementations might not be able to
work with that implementation.

> sure, you can archive the same thing without using tunnel interfaces.
> But i wonder if that creates a simple solution, easy to understand.

Unfortunately there is no simple or easy solution.  We just want to get
it working at all.

> my basic question is: how will these changes affect setups with tunnel
> interfaces?=20

I think you would see the packet even more often:

1) LOCAL_OUT of original packet=20
2) POST_ROUTING of original packet
3) LOCAL_OUT of tunnelled packet
4) POST_ROUTING of tunneled packet
5) LOCAL_OUT of ESP/AH packet
6) POST_ROUTING of ESP/AH packet

> [other issue]
> if we are to look at the calls to xfrm anyway: would it be possible to
> add a debugging facility for dropped packets? I know, that is not a
> netfilter issue, but I guess many people will find it problematic,
> if they cannot see what packets are dropped by the xfrm logic.
> I'm only rasing the issue, because that code is most likely put
> to the same places we are discussiong right now (ah, esp, ipip_rcv,
> ipip_xmit, ...).

yes, but I'd rather don't put both of them into one patch.

> > I'm not proposing to route before encapsulating.
>=20
> that is currently done. I'm glad if that "feature" is removed.

Again, I misunderstood you.  I do not intend to change the IPsec
implementation in any way, I just want netfilter to acommodate it.=20

> an interface, but avoiding the interface. but please keep
> tunnel with interface and tunnel without interface in sync.

What do you mean by that?  From my point of view, it should be like
(1-6) above.   This way anybody can filter on any kind of header bit at
any layer of the encapsulation.=20

> Regards, Andreas

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--GdipSGKQZT5VYjAa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAF7KCXaXGVTD0i/8RAp5kAKCyp4NWqfAHfDrD7YhEFFkxjon2hgCdElGp
wj4lLEKYOW6FbZQFTfyJFwk=
=r/lW
-----END PGP SIGNATURE-----

--GdipSGKQZT5VYjAa--
