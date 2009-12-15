From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] wireless: wext: allocate space for NULL-termination
 for 32byte SSIDs
Date: Tue, 15 Dec 2009 11:35:07 +0100
Message-ID: <1260873307.3692.10.camel@johannes.local>
References: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
	 <1260871411.3692.4.camel@johannes.local>
	 <1260871634.3692.6.camel@johannes.local>
	 <200912151130.59103.holgerschurig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-enmlCh9FePsTAm0KgNKC"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	daniel-rDUAYElUppE@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	m.hirsch-5g8ninUHluJWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Holger Schurig <holgerschurig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200912151130.59103.holgerschurig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-enmlCh9FePsTAm0KgNKC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-12-15 at 11:30 +0100, Holger Schurig wrote:
> > drivers/net/wireless/libertas$ grep lbs_deb_ * | grep ssid
> > |grep '%s'=20
> > assoc.c:	lbs_deb_join("current SSID '%s', ssid length %u\n",
> > assoc.c:	lbs_deb_join("requested ssid '%s', ssid length %u\n",
> > assoc.c:	lbs_deb_join("ADHOC_START: SSID '%s', ssid
> >               length %u\n",=20
> > scan.c:		lbs_deb_wext("set_scan, essid '%s'\n",
>=20
> All those lines are gone once my cfg80211 lands.
>=20
> Do you know any way to make sparse moan about them?

Sorry, no, I don't think that's even possible unless you play dirty with
tricks like __iomem uses for instance but that'd require a lot of
casting in otherwise valid uses.

> BTW: the libertas firmware sometimes treat an SSID as a=20
> zero-terminated string. There are some firmware commands that=20
> accept just an u8[32] bytes for the SSID, but not an ssid_len,=20
> e.g. in the CMD_802_11_AD_HOC_START command.
>=20
> You therefore can't connect to the otherwise legitimate SSID of=20
> TEST\0\0\0.

Ick! I guess your cfg80211 IBSS join handler needs to check for that
then and refuse such an SSID.

johannes


--=-enmlCh9FePsTAm0KgNKC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLJ2ZXAAoJEODzc/N7+QmaahEP/1NGgdmZvOQkHwhv+HpRjB3W
kmZn6tcnlmzeUyKXEHAwIKHC8a3qCvlIXEA4uBX14hN+QJZ5UxQkgV32tvtCvnQ2
6hefyDx/54a/3nfYoQP4AWowjUGHxLa2LVHkzqtL+IT824keG2zvDVeccU5VqBed
O89bkHESKRKrEbyrAM7AXE853DPou45rIXfcVm4vg+GNR8+su9egRYHp2ZYaJrIa
zl/N+Vp+jc74XTZ2LgpSXoANoo2kOjoQ79TehrL1ZpBXsfuFGuiP4dQDi9viva9/
NT9kRo4aA54qBj5OyTwI7M3BZzkpKZOfDDsXcTobgj8K76Y2poG/Aadm9cMIBI4J
oKuP5QTuY7dFBd5tjUDeqEgrgYJytyUEp+vc0IT7bOuFrNdHswnouZJPH84nyHnP
SIKw9WE5t5CL0+5Uw9j3md5VaOmQ459AXKcQ6l4W/iBljYxjIMpBYlxHWI72feAd
fjYpbdcQ8OlXwBJYN1QTTmw4bzHXRpXZdckxsjvlGL+Eih87MCT5FmRT3ye2CPbx
OnC9iedbQVD3fslgmjLsImCtIsgvJTT6PmhGnTd2hKqG9peSDwWKGantcwbmMuhk
7hrX2H7d9GInvk8SMbXoSK/RRrx0cvGKB8nBkmxz1hqvKRRsQNqAxzRPqPx4HONi
ZHodVwpcEJK7X3skWwiy
=Niwt
-----END PGP SIGNATURE-----

--=-enmlCh9FePsTAm0KgNKC--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
