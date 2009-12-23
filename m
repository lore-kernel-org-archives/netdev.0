From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [patch 1/2] proc_fops: convert drivers/isdn/ to seq_file
Date: Wed, 23 Dec 2009 13:30:25 +0100
Message-ID: <4B320D61.4070403@imap.cc>
References: <200912220025.nBM0PVBC005140@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig16CC631348114E8EBFB1D1F9"
Cc: akpm@linux-foundation.org, isdn@linux-pingi.de,
	netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:58561 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751669AbZLWMfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 07:35:19 -0500
In-Reply-To: <200912220025.nBM0PVBC005140@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig16CC631348114E8EBFB1D1F9
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Am 22.12.2009 01:25 schrieb akpm@linux-foundation.org:
> From: Alexey Dobriyan <adobriyan@gmail.com>
>=20
> Convert code away from ->read_proc/->write_proc interfaces.  Switch to
> proc_create()/proc_create_data() which make addition of proc entries
> reliable wrt NULL ->proc_fops, NULL ->data and so on.

Nice work, certainly an overall win.

> --- a/Documentation/isdn/INTERFACE.CAPI~proc_fops-convert-drivers-isdn-=
to-seq_file
> +++ a/Documentation/isdn/INTERFACE.CAPI
> @@ -149,8 +149,8 @@ char *(*procinfo)(struct capi_ctr *ctrlr
>  	pointer to a callback function returning the entry for the device in
>  	the CAPI controller info table, /proc/capi/controller
> =20
> -read_proc_t *ctr_read_proc
> -	pointer to the read_proc callback function for the device's proc file=

> +const struct file_operations *proc_fops
> +	pointers to callback functions for the device's proc file
>  	system entry, /proc/capi/controllers/<n>; will be called with a
>  	pointer to the device's capi_ctr structure as the last (data) argumen=
t
> =20

As already noted in my mail dated 28.11.2009 13:26, the result of this is=

incorrect.

The new proc_fops callback functions do *not* receive the capi_ctr pointe=
r
as an argument. Instead, they must now retrieve it starting from their fi=
le
pointer argument, via PDE(file)->data which will contain a pointer to a
seq_file structure. The private field of that structure will then contain=

the required capi_ctr pointer.

So it's not enough to just replace "pointer" by "pointers" here. The seco=
nd
half of the paragraph needs to be adapted, too.

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)


--------------enig16CC631348114E8EBFB1D1F9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org/

iEYEARECAAYFAksyDW0ACgkQQ3+did9BuFtjBgCdH5IN4eruSRVr8yjoBsj8tkn9
C/kAnjv7lhPG2b7xnpEq+U3IoW/7H/Bv
=+EJy
-----END PGP SIGNATURE-----

--------------enig16CC631348114E8EBFB1D1F9--
