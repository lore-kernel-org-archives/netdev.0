From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 3/3] r8169: increase the lifespan of the hardware
 counters dump area.
Date: Mon, 7 Sep 2015 11:29:49 +0200
Message-ID: <20150907092949.GH30539@calimero.vinschen.de>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
 <fb3db9039225ed3a030e779565b8e11f99fc8ae2.1441454454.git.romieu@fr.zoreil.com>
 <20150906103732.GF30539@calimero.vinschen.de>
 <20150906202153.GB19371@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="HB4mHL4PVvkpZAgW"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	pomidorabelisima@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:42344 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbbIGJ3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 05:29:53 -0400
Content-Disposition: inline
In-Reply-To: <20150906202153.GB19371@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--HB4mHL4PVvkpZAgW
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep  6 22:21, Francois Romieu wrote:
> Corinna Vinschen <vinschen@redhat.com> :
> > On Sep  5 14:18, romieu@fr.zoreil.com wrote:
> [...]
> > > - rtl_reset_counters_cond induced failures in open() are also conside=
red
> > >   fatal: it takes acceptable work to unwind comfortably.
> >=20
> > Why?
>=20
>=20
> Crap, my description does not match the code wrt rtl_reset_counters_cond.=
 :o/
>=20
> s/rtl8169_reset_counters/rtl8169_update_counters/g
>=20
> The code is right.
>=20
> [...]
> > This returns -EINVAL even for older chip versions which are not capable
> > of resetting the counters.  The result is, this driver will not work at
> > all on chip versions prior to RTL_GIGA_MAC_VER_19 anymore, because
> > rtl_open will always fail.
>=20
> No. My changelog was misleading. rtl_init_counter_offsets handles this pa=
rt
> correctly.

Oh, right, I missed that rtl_init_counter_offsets checks for `if (!rc)',
not for `if (rc < 0)' as for the call to rtl8169_update_counters.

Still wondering though.  Given that the driver never failed before if
the counter values couldn't be updated, and given that these counter
values only have statistical relevance, why should this suddenly result
in a fatal failure at open time?


Corinna

--HB4mHL4PVvkpZAgW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV7VkNAAoJEPU2Bp2uRE+gzc8QAI39PjMyPL0kyQCE0OPUBkhY
XJg+bqZA+fk9Ycq6aDsNTX1go4/OgVwRa43XiKrMaQ7kiTmNVlc6IQhIVqnAcCDS
/qjDLQM9jHox+1k5RBejoKTazjknLbP88/1Vn0ma1QIgRJ8/h9xeGI7xCRla3oD5
lRGwqwD0kQVOv1LxTqG+bAAbdPrqWOBHyiipltBblL3pCebRvWfjSJxajDDdiGeI
F+K4O9nYu3AV/Ai3CW0hqPcBXNbomV8g0JBPKVxwneiRyspqx0NOwGJ5X3FLYv/l
b/YB+FPZZ4/77Fi96TtIb3+iCaq5NOqtIkDeIqeTdP2jxomr5kO1lsR7tbrao9ck
1rA1M69aTuAmx5/BAS9jAne3Trn35cw/KLrzklLFfgsDNoYinwFPGmCBnwNE640B
7o85JT6PBve/Agf6iFhMpLxAWGMVWRBb8BZTTN6rVKwm4dyrSBK8Gb0btddDCCwE
KlDDzsVYg0AxLNzMWeS1TfFHjD2QEoSYTTNil0HG65uUmD2AEILtA3sQ5u8hGpS+
AC+bfinhYnPESceOk2j+iy9s4NaG3F69xnKfFDejYnlqEm6c/J5bzd5hnBYw/otc
enNRxiuoyk8xMa+eFJ2zNwH/wFo6xzR77aIc4T5wyHjZaetH6BHGSsJFacaEKUQL
XGbrchoN03c/R5pP51gs
=BzI+
-----END PGP SIGNATURE-----

--HB4mHL4PVvkpZAgW--
