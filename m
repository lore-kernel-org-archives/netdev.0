From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Wrong source MAC for 8021q VLAN interfaces with TX VLAN offload
 enabled
Date: Sun, 09 Mar 2014 16:39:47 +0000
Message-ID: <1394383187.2861.137.camel@deadeye.wl.decadent.org.uk>
References: <53162BA6.9080707@netrounds.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-TR12kOirCkGp4cPmDk8k"
Cc: netdev@vger.kernel.org
To: Peter =?ISO-8859-1?Q?Bostr=F6m?= <peter.bostrom@netrounds.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50918 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750771AbaCIQj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 12:39:57 -0400
In-Reply-To: <53162BA6.9080707@netrounds.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TR12kOirCkGp4cPmDk8k
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-03-04 at 20:38 +0100, Peter Bostr=C3=B6m wrote:
> Hello
>=20
> The patch committed as 2205369a314e12fcec4781cc73ac9c08fc2b47de (vlan:
> Fix header ops passthru when doing TX VLAN offload.) seems to have
> introduced a bug for me. It's reproducible in the current 3.14-rc5 as
> well as older versions for which the patch was applied.
[...]
> A potential fix is to set the saddr in the vlan_passthru_hard_header
> function.
> This works for me. But since I lack a good understanding of how the TX
> VLAN offload actually works I can't really tell whether this is a
> proper solution or not.
> Any input would be appreciated.
>=20
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -538,6 +538,9 @@
>       struct vlan_dev_priv *vlan =3D vlan_dev_priv(dev);
>       struct net_device *real_dev =3D vlan->real_dev;
>=20
> +    if (!saddr)
> +        saddr =3D dev->dev_addr;
> +
>       return dev_hard_header(skb, real_dev, type, daddr, saddr, len);
>   }
>=20

This makes sense to me.  You should re-send this patch with proper
formatting and your sign-off (see Documentation/SubmittingPatches,
Documentation/email-clients.txt).

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-TR12kOirCkGp4cPmDk8k
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxyZU+e/yOyVhhEJAQrAZxAAkEa87BOiO8lbnu95C+T0QO33/XP1jLTW
/ic2pb5KUYddWDBOkv5hm7ZLSEc8ydelSbcXqhiaM6KHNI8JNgOoAd3Lt8dNwoFb
GxSs6uDaGB6krnhi5ygnq10ciSH7M1kJrm81xxnKsAZvvuUuWle/qrn+LsPWUlmZ
Yitsez2npAjsTtvviPOPIAW5QUnEQKB4kzpj4H8GJhze35E0bEsOwSz7cJyf2zfL
xEr/7xhWOSnIiuHZGx+LbihxrmR+strwzWBF15Difrw63gCa13A85UJJt16MstJi
HgWXKouIH3WLKPCbcUuszhiadV9ZGikmV+p+VMiVwqBrV9vK+UGBSMnOHBFrkPH6
CTtS93ClC5cWeancqfQLtqyp9R3PgnJ1Hv908Db/p2Kl8zwLPya2iGlji6baONVw
w/phBzHhVYkS1WOrjt6LHeEamLS6pN+gnq/SETpJTcqYAS3zb/EML6wdaRt/nBmP
3HYC4ZD1wtiXHGuxJRqxySbcfc/HzOb3xTj01WPuIQlO618AlUoPqPik+67+XMKI
byOzYPwpQawdjSn4kRjQji178oCujJD+jisWxid813s3pKosVTBolFJISoU/DaE2
BAwyJf9V8uy0KU2NqEiSPMyJL9fJ6IKMoEKOTd3nF+7FmcvwcVEPpWG9fjgHw+0u
mnt+zOkfSew=
=gKe6
-----END PGP SIGNATURE-----

--=-TR12kOirCkGp4cPmDk8k--
