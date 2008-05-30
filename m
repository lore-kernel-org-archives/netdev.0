From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Subject: Re: race between rtl8187_stop and rtl8187_rx_cb?
Date: Fri, 30 May 2008 00:15:33 -0400
Message-ID: <200805300015.41406.flamingice@sourmilk.net>
References: <200805162201.07634.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1251958.KiOhrZHdQk";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrea Merello <andreamrl-IWqWACnzNjyonA0d6jMUrA@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200805162201.07634.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart1251958.KiOhrZHdQk
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 16 May 2008 16:01:06 Oliver Neukum wrote:
> rtl8187_stop() works by emptying a queue and unlinking urbs. But
> an urb finishing will be taken from the queue in rtl8187_rx_cb until
> it is resubmitted. Am I overlooking something or is there a window?
>
It appears that if you're unlucky, a rx urb can end up getting requeued aft=
er=20
the dequeue loop in rtl8187_stop on a SMP system. Good catch. Doesn't look=
=20
like it'll cause much trouble other than leaving urbs/skbs unfreed when the=
=20
interface is down, but it's worth fixing. This requires information about=20
whether or not the interface is started or stopped. Preferred way would be =
to=20
set priv->mode =3D IEEE80211_IF_TYPE_INVALID in rtl8187_stop and priv->mode=
 =3D=20
IEEE80211_IF_TYPE_MNTR in rtl8187_start, so we can check for priv->mode =3D=
=3D=20
IEEE80211_IF_TYPE_INVALID before requeueing the urb in rtl8187_rx_cb.=20

Thanks,
=2DMichael Wu

--nextPart1251958.KiOhrZHdQk
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)

iD8DBQBIP39tT3Oqt9AH4aERAkvgAKCcMp0rnyxpiNJxMWEUwUYuOtB6+wCffQqE
r9w88xaK7Ak2E0oKIJ/0UNM=
=gfl+
-----END PGP SIGNATURE-----

--nextPart1251958.KiOhrZHdQk--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
