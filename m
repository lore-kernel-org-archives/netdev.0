From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: [PATCH 31/31] CAPI: Officially claim char major 191
Date: Sat, 23 Jan 2010 15:49:46 +0100
Message-ID: <4B5B0C8A.7090603@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>	 <20100123122430.5a078b4a@lxorguk.ukuu.org.uk>	 <1264250892.3469.52.camel@violet>  <201001231432.09918.isdn@linux-pingi.de> <1264256908.3469.58.camel@violet>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigADE235F96C9AA14D4A6B8704"
Cc: isdn@linux-pingi.de, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@linux.intel.com>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755846Ab0AWOt4@vger.kernel.org>
In-Reply-To: <1264256908.3469.58.camel@violet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigADE235F96C9AA14D4A6B8704
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Marcel Holtmann wrote:
> Hi Karsten,
>=20
>>>>> I found no trace of this mysterious "pcl181" device, neither in-tre=
e
>>>>> nor out there in the wild. At the same time, the in-tree CAPI
>>>>> middleware is using major 191 for many years now and obviously with=
out
>>>>> any conflict. Let's officially claim this major number.
>>>> This is not the way it should have been done but whoever needs spank=
ing
>>>> got away with it years ago. Given that this seems the best way forwa=
rd.
>>>>
>>>> With LANANA hat on
>>> actually in the days of udev, the capifs is not really needed anymore=
=2E
>>> The right choice would be to remove it. I haven't been enabling it si=
nce
>>> years.
>>>
>> So far I understand, the pppd capiplugin is the only user of it, so it=
 could=20
>> be disabled for most users without any problems, as long they are not =
using
>> PPP connections via CAPI.
>=20
> PPP connection via CAPI works just fine without capifs. You just need
> udev to create the device nodes.
>=20
>> I never understand capifs very well, I think that it can be dropped be=
cause of=20
>> udev, but maybe need some adjustment in user space as well (make sure =
that
>> udev did create the node before  open it).
>=20
> I am pretty sure that I send a patch for that a long long time ago. I
> haven been using CAPI + PPP without capifs.
>=20
>> I f I remember correctly, here was some proposal  to replace the /dev/=
capi/=20
>> nodes with  devpts, this would remove the complete capi_tty device maj=
or
>> as well.
>=20
> Don't remember anything like this. However extending the kernel code
> with a CAPI PPP channel type would be better actually.

Not sure how much of pppdcapiplugin would have to be moved into the
kernel then, but if it allows us to even drop that thing, it might be
worth it.

In any case, I think we first need a solution for existing user space.
So if pppdcapiplugin can be safely considered the only user of
/dev/capi/*, I will rework my series to use a dynamic major and will
file a patch to first deprecate and then remove capifs. What would be a
reasonable warning period? Something like 3 kernel releases?

Jan


--------------enigADE235F96C9AA14D4A6B8704
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAktbDI4ACgkQitSsb3rl5xRIXwCgsZtRjhq2zCohGg0y90nv4NEy
t5QAoIJMEM6RmSHz+2B+ZQYM8FA50swO
=Ha6D
-----END PGP SIGNATURE-----

--------------enigADE235F96C9AA14D4A6B8704--
