From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool 2/5] ethtool: Add missing Advertised speeds
Date: Sun, 05 Apr 2015 03:29:47 +0100
Message-ID: <1428200987.11260.148.camel@decadent.org.uk>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
	 <1422193883-30504-3-git-send-email-amirv@mellanox.com>
	 <1428197864.11260.121.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QLVePtSQduJOxkIL0Wqw"
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	Hariprasad S <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58768 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751407AbbDECaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 22:30:03 -0400
In-Reply-To: <1428197864.11260.121.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-QLVePtSQduJOxkIL0Wqw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

[Adding in maintainers of drivers that can report FEC ability.]

On Sun, 2015-04-05 at 02:37 +0100, Ben Hutchings wrote:
[...]
> >  		{ 0, ADVERTISED_10000baseKX4_Full,  "10000baseKX4/Full" },
> >  		{ 0, ADVERTISED_10000baseKR_Full,   "10000baseKR/Full" },
> > +		{ 0, ADVERTISED_10000baseR_FEC,     "10000baseR/FEC" },
>=20
> This is not a link mode, it's a separate capability that applies to all
> 10GBASE-R modes.  It's also meaningful for 40G and 100G modes despite
> the way we've named the flags.  Please put it in a separate section
> below the link modes.

So how about reporting FEC ability like this, using a slightly generic
heading to allow for other similar options in future?

diff --git a/ethtool.c b/ethtool.c
index 7e5fa9d..3badf5e 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -560,6 +560,12 @@ dump_link_caps(const char *prefix, const char *an_pref=
ix, u32 mask,
 	fprintf(stdout, "\n");
=20
 	if (!link_mode_only) {
+		fprintf(stdout, "	%s link options: ", prefix);
+		if (mask & ADVERTISED_10000baseR_FEC)
+			fprintf(stdout, "baseR-FEC\n");
+		else
+			fprintf(stdout, "None\n");
+
 		fprintf(stdout, "	%s pause frame use: ", prefix);
 		if (mask & ADVERTISED_Pause) {
 			fprintf(stdout, "Symmetric");
--- END ---

Ben.

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-QLVePtSQduJOxkIL0Wqw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVSCeIOe/yOyVhhEJAQpXUg//VikaUCelPhFc1lGgaSWQcXniEwjwu1w+
0O9Ru90dmvzImrk+xNcJDQHX55BV3SzNUvWsaJnRtFtol0LDnQGhxt1CBIBOPZ1v
qC7bq1df/B+Jt3IXPBjyIj9HzJX6ziYbJ8Bigzs9Yay8bCpuI6M8IRzYfwD4ONSq
szSdzdLI/8R/vP9gVqTy3khoabZpZfONhCHxtg6rEhD7qitWW/bfeDzu4wyIp+wS
DPx4VUOMT04ghVXWyc8qbWx93wZ44UTdrEQZufXZGyt9v7mvsGOxVpvZNd5AlWMX
JC6ynR0jC6xfpR8C4gzCiTk6Hnr0krxqzwFaGgvZtMdmMqjbHMA7XbeTX5vKB0Q3
TaPzS0nihFHUb06eUxRJFyv/dWSDVwc5rN8TIWBd8QtRir1smbCDjjcMbPm/SkET
PxxO1G+Zb//m5JMFM0F57CHM9o6foprVuvPvaJEnF9gZWwXEV2+aLkcZMIaB38Jl
La/msLEFVdwq0278kXLWjDE6NMQy3IAGFL7jgvP/48HeHrhm+wT4/MzS5Hm2XgvH
mDt86KhN05jZ8L/GhpEvGjMnfxGQ8dccFoT6A7H2zIaPLmb6quoGzasgne5y5ZLo
tIMDbcAkKGA6brGPmjjMVFBUP0nVMgk04YEym94SiGpCPzjvq2PCVu3SZd5+PUKS
A6ZFY01VFE4=
=owld
-----END PGP SIGNATURE-----

--=-QLVePtSQduJOxkIL0Wqw--
