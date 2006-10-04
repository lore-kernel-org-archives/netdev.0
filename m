From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take19 0/4] kevent: Generic event handling mechanism.
Date: Wed, 04 Oct 2006 00:33:25 -0700
Message-ID: <452363C5.1020505@redhat.com>
References: <115a6230591036@2ka.mipt.ru> <11587449471424@2ka.mipt.ru> <20060927150957.GA18116@2ka.mipt.ru> <a36005b50610032150x8233feqe556fd93bcb5dc73@mail.gmail.com> <20061004045527.GB32267@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2C7F6BDD534D56E271BDC5B4"
Cc: Ulrich Drepper <drepper@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161112AbWJDHcM@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061004045527.GB32267@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2C7F6BDD534D56E271BDC5B4
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Evgeniy Polyakov wrote:
> When we enter sys_ppoll() we specify needed signals as syscall
> parameter, with kevents we will add them into the queue.

No, this is not sufficient as I said in the last mail.  Why do you
completely ignore what others say.  The code which depends on the signal
does not have to have access to the event queue.  If a library sets up
an interrupt handler then it expect the signal to be delivered this way.
 In such situations ppoll etc allow the signal to be generally blocked
and enabled only and *ATOMICALLY* around the delays.  This is not
possible with the current wait interface.  We need this signal mask
interfaces and the appropriate setup code.

Being able to get signal notifications does not mean this is always the
way it can and must happen.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96


--------------enig2C7F6BDD534D56E271BDC5B4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFFI2PF2ijCOnn/RHQRAk+TAKC6jf1yoYInqCZc7OZMeDj2oKptRACbBC7j
rrtN99wYR8Iu9QQrqtd+aqg=
=/HVc
-----END PGP SIGNATURE-----

--------------enig2C7F6BDD534D56E271BDC5B4--
