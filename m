From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH RFC] isdn/capi: fix up CAPI subsystem workaround locking
 a bit
Date: Tue, 06 Oct 2009 19:52:55 +0200
Message-ID: <4ACB83F7.9040500@imap.cc>
References: <20091003120657.2228911186C@xenon.ts.pxnet.com> <200910032035.21884.mb@bu3sch.de> <4AC9DBA5.1090701@imap.cc> <200910052324.09992.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig123FB9C4A91B62E09C2BE7C1"
Cc: i4ldeveloper@listserv.isdn4linux.de,
	Carsten Paeth <calle@calle.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>,
	Armin Schindler <armin@melware.de>,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932971AbZJFRyO@vger.kernel.org>
In-Reply-To: <200910052324.09992.mb@bu3sch.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig123FB9C4A91B62E09C2BE7C1
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-10-05 23:24:07 +0200, Michael Buesch wrote:
> On Monday 05 October 2009 13:42:29 Tilman Schmidt wrote:

>> Thanks for the info. So do I understand correctly that after:
>>
>> commit 6aa65472d18703064898eefb5eb58f7ecd0d8912
>> Author: Michael Buesch <mb@bu3sch.de>
>> Date:   Mon Jun 26 00:25:30 2006 -0700
>>
>>     [PATCH] CAPI crash / race condition
>>
>> you were actually still seeing LIST_POISON2 Oopses in
>> capiminor_del_ack(), but after:
>=20
> Yeah well. The oops with LIST_POISON was with a patch that converted th=
e
> datahandle_queue to struct list_head, but without the spinlock_t ackqlo=
ck added.
> Then I added the spinlock_t ackqlock and it first seemed to fix the pro=
blem. (That
> is the patch from the mail).

Understood.

> But it did only shrink the race window, so the crash did still happen, =
but less often.

Ok.

> The crash was only "fixed" with the workaround_lock patch (but _without=
_ any of the
> ackqueue patches applied.)
>=20
>> commit 053b47ff249b9e0a634dae807f81465205e7c228
>> Author: Michael Buesch <mb@bu3sch.de>
>> Date:   Mon Feb 12 00:53:26 2007 -0800
>>
>>     [PATCH] Workaround CAPI subsystem locking issue
>>
>> they were gone? That's interesting. I'll try to wrap my mind around
>> this.
>=20
> Yeah, this sledgehammer lock did fix the crash while leaving the old no=
n-list-head
> queue in place (it should still be there today).

That is not the case. In mainline, your second patch was applied on
top of the first one, so there is now struct list_head ackqueue and
spinlock_t ackqlock as well as static DEFINE_SPINLOCK(workaround_lock).

>> It's unfortunate that these crashes only seem to occur with one specif=
ic
>> device (FritzCard DSL) which I don't have.
>=20
> I still have the device somewhere. If you want to have it, I can blow o=
ff the
> dust and send it to you. If you don't want it, I'll throw it away soon.=

> I'd really like to send it to you to get rid of it. ;)

Feel free to do so. I'll send you my snailmail address by PM. I'm
making no promises about when I might get around to actually testing
it, though.

>> Can anyone shed some light on=20
>> what that device is doing differently from other ISDN cards?
>=20
> Well, it's a combined ISDN/DSL card, but I never used the ISDN part. So=
 the crash
> happened while transferring data over the DSL link.

DSL over CAPI? Strange.

> The vendor driver is closed source with an open wrapper (like nvidia). =
It's a pretty
> crappy unmaintained piece of software, but it ran stable with some patc=
hes applied
> to the driver and the workaround-lock patch to the capi stack.

O dear. I wonder what I'll find.

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)


--------------enig123FB9C4A91B62E09C2BE7C1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFKy4QBQ3+did9BuFsRAsCcAJ4w+pG8PpXC/rKcqukzgaN2Fj3HJQCeLrs8
iWIxNbtGEDJj/LT5bTjGhfw=
=bwwl
-----END PGP SIGNATURE-----

--------------enig123FB9C4A91B62E09C2BE7C1--
