From: Sven Anders <sven@anduras.de>
Subject: Re: [PATCH] e1000e: Fix usage under kexec
Date: Fri, 04 Dec 2009 10:10:35 +0100
Message-ID: <4B18D20B.5070204@anduras.de>
References: <4AF87AB1.1070603@anduras.de> <4B026B24.5040108@redhat.com> <EA929A9653AAE14F841771FB1DE5A1365FA68EE924@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigBE4FAAE96D4301CAE592A641"
Cc: Stefan Assmann <sassmann@redhat.com>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metropolitan.anduras.de ([80.237.200.159]:33863 "EHLO
	metropolitan.anduras.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755196AbZLDJKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 04:10:39 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FA68EE924@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigBE4FAAE96D4301CAE592A641
Content-Type: multipart/mixed;
 boundary="------------020905090207040000050909"

This is a multi-part message in MIME format.
--------------020905090207040000050909
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Tantilov, Emil S schrieb:
> Stefan Assmann wrote:
>> On 09.11.2009 21:25, Sven Anders wrote:
>>>
>>> We're experiencing the following problem:
>>>
>>> We start a minimal linux system, prepare the system and start the
>>> final system via kexec. On two different systems (one with a 82573
>>> and one with a 82574), the driver cannot initialize the network
>>> hardware, because the PHY is not recognized.=20
>>>
>>> We get the following error:
>>>   e1000e: probe of 0000:02:00.0 failed with error -2
>> Hi Sven,
>>
>> have a look at the following thread, it seems very similar.
>> http://kerneltrap.org/mailarchive/linux-netdev/2009/3/7/5114394
>=20
> There is already similar code in e1000e:
> http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcommi=
t;h=3D4f9de721ab73a5271a79b126f7b5140b01a05c99

Yes it sound similar. We will test this when we upgrade the kernel for
our next OS release...

> Sven, could you provide some additional information about your system a=
nd=20
> kernel/driver verison you used when the issue occurred?
> I have not been able to reproduce it on my setup.

Currently we are using the Linux kernel 2.6.29.6 for our appliances.
Which is/was the first officially released kernel with this patch?



Andi Kleen wrote:
>> We fixed it by adding a
>> >
>> > +       /* Reset PHY before initializing it. Allows re-init after ke=
xec. */
>> > +       if (!e1000_check_reset_block(hw))
>> > +         e1000_phy_hw_reset(hw);
>=20
> The problem of resetting PHYs in the driver init path is that it tends
> to lose link-state, and if the link takes some time to re-negotiate
> you can significantly slow down the "total time to network access"
> at boot.
>=20
> Perhaps you could only reset when the message above would trigger
> and try again?
>=20
> -Andi

Ok, know we are doing the following. But maybe it isn't needed with the
new kernel any more...

@@ -109,6 +109,13 @@ static s32 e1000_init_phy_params_82571(s
        /* This can only be done after all function pointers are setup. *=
/
        ret_val =3D e1000_get_phy_id_82571(hw);

+       /* Could not determine PHY id. This can happen when booting
+          via kexec. So reset and try again. */
+       if (ret_val =3D=3D -E1000_ERR_PHY) {
+               e1000_phy_hw_reset(hw);
+               ret_val =3D e1000_get_phy_id_82571(hw);
+       }
+
        /* Verify phy id */
        switch (hw->mac.type) {
        case e1000_82571:


Regards
 Sven Anders

--=20
 Sven Anders <anders@anduras.de>                 () Ascii Ribbon Campaign=

                                                 /\ Support plain text e-=
mail
 ANDURAS service solutions AG
 Innstrasse 71 - 94036 Passau - Germany
 Web: www.anduras.de - Tel: +49 (0)851-4 90 50-0 - Fax: +49 (0)851-4 90 5=
0-55

Those who would give up essential Liberty, to purchase a little
temporary Safety, deserve neither Liberty nor Safety.
  - Benjamin Franklin

--------------020905090207040000050909
Content-Type: text/x-vcard; charset=utf-8;
 name="sven.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="sven.vcf"

YmVnaW46dmNhcmQNCmZuOlN2ZW4gQW5kZXJzDQpuOkFuZGVycztTdmVuDQphZHI7cXVvdGVk
LXByaW50YWJsZTo7O1dlaWRlc3RyYT1DMz05RmUgMTk7SGFubm92ZXI7TmllZGVyc2FjaHNl
bjszMDQ1MztEZXV0c2NobGFuZA0KZW1haWw7aW50ZXJuZXQ6c3ZlbkBhbmR1cmFzLmRlDQp0
ZWw7aG9tZTorNDkgKDApNTExIC8gMjEyMzA5MA0KdGVsO2NlbGw6KzQ5ICgwKTE3MCAvIDgw
OTExODANCngtbW96aWxsYS1odG1sOkZBTFNFDQp1cmw6aHR0cDovL3N0YWZmLmFuZHVyYXMu
ZGUvYW5kZXJzDQp2ZXJzaW9uOjIuMQ0KZW5kOnZjYXJkDQoNCg==
--------------020905090207040000050909--

--------------enigBE4FAAE96D4301CAE592A641
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAksY0hMACgkQ5lKZ7Feg4EfOJgCfU5I3O021YBUPzDhuc6lpBa8c
kNwAoIyiB1V3s9V6SHn3Rl0aBjWM0oCE
=MmyV
-----END PGP SIGNATURE-----

--------------enigBE4FAAE96D4301CAE592A641--
