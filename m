From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] connector: Kernel connector - userspace <-> kernelspace
	"linker".
Date: Fri, 24 Sep 2004 10:14:30 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096006470.17587.37.camel@uganda>
References: <1095331899.18219.58.camel@uganda>
	 <20040921124623.GA6942@uganda.factory.vocord.ru>
	 <20040924000739.112f07dd@zanzibar.2ka.mipt.ru>
	 <20040923215447.GD30131@ruslug.rutgers.edu>
	 <1095997232.17587.8.camel@uganda>
	 <20040924054844.GO30131@ruslug.rutgers.edu>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-OUKycYtgexc6m67+nI/q"
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
In-Reply-To: <20040924054844.GO30131@ruslug.rutgers.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-OUKycYtgexc6m67+nI/q
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2004-09-24 at 09:48, Luis R. Rodriguez wrote:
> On Fri, Sep 24, 2004 at 07:40:32AM +0400, Evgeniy Polyakov wrote:
> > On Fri, 2004-09-24 at 01:54, Luis R. Rodriguez wrote:
> > > RFC:=20
> > >=20
> > > Can and should we work towards using this as interface for drivers th=
at
> > > need callbacks from an external (closed source) library/HAL?
> >=20
> > As I mentioned to Richard Jonson, it can be considered as
> > ioctl. ioctl-ng!
> > Unified interface (as ioctl) can be used for any type of modules.
> > It is just a bit extended ioctl :)
> >=20
> > And _yes_, it can be used to turn on/off binary-only callbacks.
> > Remember pwc - closed part can register callback and open part can
> > send message, or even closed part can register notification when
> > open part registers itself and begin to "trash the kernel".
> >=20
> > I understand that it is not right way to include it is into the kernel,
> > but I personally do not understand how it is different=20
> > from just extended ioctl. It was designed to be usefull and convenient,
> > and it is.
> >=20
> > BTW, any binary-only module can _itself_ create netlink socket
> > with input callback. And that is all - it will be absolutely
> > the same as above.
> >=20
> > One may consider connector as yet-another-netlink-helper.
> >=20
>=20
> Eh. I'm just wondering if there's any *right* way of using binary
> callbacks on a linux driver so that it doesn't *taint* and possibly
> *trash it*, as you said. I was wondering if perhaps through the
> connector we could somehow protect the kernel of possibly ill-behaved cal=
lbacks.
>=20
> Comments?

Yes, we can.
Connector itself has quite enough information about it's registrants.

For example if it is somehow not good module( for example without GPL in
it's license string) then connector can be extended to call it's
callback from thread or in jail. If it is of interest I will think of
some plugable mechanism for callback environment( probably provide
->before_callback() and ->after_callback() methods from external policy
provider which may check callback data and/or confine callback execution
? ).

We also may confine closed modules from being able to use event
notification. In this scenario with worned out pwc-closed/open,
situation will not differ from what we have now.

> 	Luis
--=20
	Evgeniy Polyakov

Crash is better than data corruption. -- Art Grabowski

--=-OUKycYtgexc6m67+nI/q
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBU7tGIKTPhE+8wY0RAhTqAJ0bDobit+gdUDKlL7W8zi900INwJACdGfC6
wgjevYUKMLT3Rv2gYXkw7r4=
=5XJj
-----END PGP SIGNATURE-----

--=-OUKycYtgexc6m67+nI/q--
