From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] connector/CBUS: new messaging subsystem. Revision number
	next.
Date: Wed, 27 Apr 2005 09:32:06 +0400
Message-ID: <1114579926.14282.16.camel@uganda>
References: <20050411125932.GA19538@uganda.factory.vocord.ru>
	 <d120d500050426130250ff9632@mail.gmail.com>
	 <1114574809.14282.10.camel@uganda>
	 <200504270016.34002.dtor_core@ameritech.net>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-bJZJoCAojCcVx3lKkpfO"
Cc: netdev@oss.sgi.com, Greg KH <greg@kroah.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Morris <jmorris@redhat.com>,
	Guillaume Thouvenin <guillaume.thouvenin@bull.net>,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	Thomas Graf <tgraf@suug.ch>, Jay Lan <jlan@engr.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261511AbVD0FZX@vger.kernel.org>
To: Dmitry Torokhov <dtor_core@ameritech.net>
In-Reply-To: <200504270016.34002.dtor_core@ameritech.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-bJZJoCAojCcVx3lKkpfO
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2005-04-27 at 00:16 -0500, Dmitry Torokhov wrote:
> On Tuesday 26 April 2005 23:06, Evgeniy Polyakov wrote:
> > Let's clarify that we are talking about userspace->kernelspace
> > direction.
> > Only for that messages callback path is invoked.
>=20
> What about kernelspace->userspace or kernelspace->kernelspace?
> From what I see nothing stops kernel code from calling cn_netlink_send,
> in fact your cbus does exactly that. So I am confused why you singled
> out userspace->kernelspace direction.

You miunderstand the code -
cn_netlink_send() never ends up in callback invocation,=20
it can only deliver messages in kernelspace->userspace direction.
kernelspace->userspace direction ends up adding buffer into
socket queue, from which userspace may read data using recv() system
call.
There is no kernelspace->kernelspace sending possibility=20
except by creating new socket in userspace and sendmsg/recvmsg=20
interception/using, but that is the same as reading from userspace.

--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-bJZJoCAojCcVx3lKkpfO
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCbyPWIKTPhE+8wY0RApLCAJ9qHyMFNb74RL7jIyIF4vdYoXhLUQCglYZ7
kjZPt1yOlpG5DjL9rdk52mY=
=MVUC
-----END PGP SIGNATURE-----

--=-bJZJoCAojCcVx3lKkpfO--
