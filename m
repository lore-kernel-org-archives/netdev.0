From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH 3/3] bridge: fix bridge root block on designated port
Date: Sat, 15 Mar 2014 03:08:26 +0100
Message-ID: <20140315020826.GB28801@wotan.suse.de>
References: <1394680527-28970-1-git-send-email-mcgrof@do-not-panic.com> <1394680527-28970-4-git-send-email-mcgrof@do-not-panic.com> <20140313151623.03e0484d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rS8CxjVDS/+yyDmU"
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, xen-devel@lists.xenproject.org,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140313151623.03e0484d@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--rS8CxjVDS/+yyDmU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 13, 2014 at 03:16:23PM -0700, Stephen Hemminger wrote:
> On Wed, 12 Mar 2014 20:15:27 -0700
> "Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:
>=20
> > --- a/net/bridge/br_private.h
> > +++ b/net/bridge/br_private.h
> > @@ -150,6 +150,7 @@ struct net_bridge_port
> >  	u8				priority;
> >  	u8				state;
> >  	u16				port_no;
> > +	bool				root_block_enabled;
> >  	unsigned char			topology_change_ack;
>=20
> It seems a bit confusing to have both a ROOT_BLOCK flag in the
> data structure and and additional root_block_enabled flag.
> If nothing else it is a waste of space.

Indeed, however there is a use for it. Consider the case where we loop
over each port and check to see if its root blocked and need to tickle it
or the bridge. In the case that root port block was enabled before and
someone is lifting it the flag would be removed and therefore not on
but it was root blocked though and we need a way to keep track of that.

The flag then is a toggle for userspace, while the bool tells us about
the current state.

> Looks like you are changing the meaning slightly.=20

Let me know in what way. I can't see it.

> is possible to have BR_ROOT_BLOCK set but !root_block_enabled?=20

Yeah in the case a new request to set it to root block then
BR_ROOT_BLOCK would be set but root_block_enabled would not be set.

> and what about the inverse?

BR_ROOT_BLOCK would not be set when userspace wants to disable root
port block and root_block_enabled would be enabled in this case if
it used to be enabled. So yes, both are possible.

  Luis

--rS8CxjVDS/+yyDmU
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iQIcBAEBAgAGBQJTI7YaAAoJEPep4JnvMe6ztNIP/RZehJge9AcubruD2vcmbM/w
d+LJiCu0kKCqvpyeFSN6uXlcdvCr0wCJkTspqBKLtNCmBXgrHX9E3OOUOKMHz3EL
6oXnf40NfMz4+yWrQ6dnnbUKsjzrtQ14sMz3T1iheVK9MvpHSDjoFi3XraC8NJoD
SUN+/TvgZ/7wGfDVhvOyrLrpDhnuSQm0YXGXahV/1aK1jZnbc1Fg/AT+ZLTZ7WWT
96y4G97VZagnBCqe4AQUptziGllAPeaBko7xKZL7gOiw1Kmp7cjfP62j/A2J3l1t
iwLTmHazeviqmhK3a1V1LK5KV4BPItkTv99zwXr7dmgRNuTf30UGfs+1fSjYwRy+
aXxfC+MCLLqvOUlWxLbRCnWkwi06jZPquvG8cjXsl4h8+WqurEY8u/+hvHHb2LhW
STqJCv9q/xQ3jVp6lQUvySujUZNazw+qGkgeuaff8j+DcyI3epsQ3ZS1XpBlFJXY
dCs2T3rBS45hsRrqtWKpDwcR2lpaXmw2eIU4ArQqo+OZZZq6qfe25s0wjz8dSZza
n2RhCrzwLutfRfbn3KDSf7jwVAj8MrhYfphneD7kDrMzVeKS0J95rSgSmn/yaPFu
A87BE4D2Rg5xAR/7TgghNkjXDFWm3b1+96B3L3SH6cYjnv+F1eOYbRwoKzPNtJ2i
FDGu3k5NtcQfxk6sfklJ
=BNbf
-----END PGP SIGNATURE-----

--rS8CxjVDS/+yyDmU--
