From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] be2net: Bugfix for packet drop with kernel param
 swiotlb=force
Date: Sat, 22 Feb 2014 01:49:56 +0000
Message-ID: <1393033796.15717.90.camel@deadeye.wl.decadent.org.uk>
References: <OF1C38716E.D9F528E0-ON48257C85.000A026B-48257C85.000AA8C9@zte.com.cn>
	 <e57b63ae-b1a8-47f3-8f2b-71cb6d8ab4fc@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MR9hj6n4gAEjeEVrTTDa"
Cc: "jiang.biao2@zte.com.cn" <jiang.biao2@zte.com.cn>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <Ajit.Khaparde@Emulex.Com>,
	"wang.liang82@zte.com.cn" <wang.liang82@zte.com.cn>,
	"cai.qu@zte.com.cn" <cai.qu@zte.com.cn>,
	"li.fengmao@zte.com.cn" <li.fengmao@zte.com.cn>,
	"long.chun@zte.com.cn" <long.chun@zte.com.cn>,
	David Miller <davem@davemloft.net>
To: Sathya Perla <Sathya.Perla@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55608 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753988AbaBVBuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 20:50:06 -0500
In-Reply-To: <e57b63ae-b1a8-47f3-8f2b-71cb6d8ab4fc@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MR9hj6n4gAEjeEVrTTDa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-02-20 at 09:39 +0000, Sathya Perla wrote:
> > -----Original Message-----
> > From: jiang.biao2@zte.com.cn [mailto:jiang.biao2@zte.com.cn]
> >=20
> >=20
> > From: Li Fengmao <li.fengmao@zte.com.cn>
> >=20
> > There will be packet drop with kernel param "swiotlb =3D force" on
> > Emulex 10Gb NIC using be2net driver. The problem is caused by
> > receiving skb without calling pci_unmap_page() in get_rx_page_info().
> > rx_page_info->last_page_user is initialized to false in
> > be_post_rx_frags() when current frag are mapped in the first half of
> > the same page with another frag. But in that case with
> > "swiotlb =3D force" param, data can not be copied into the page of
> > rx_page_info without calling pci_unmap_page, so the data frag mapped
> > in the first half of the page will be dropped.
> >=20
> > It can be solved by creating only a mapping relation between frag
> > and page, and deleting rx_page_info->last_page_user to ensure
> > calling pci_unmap_page when handling each receiving frag.
>=20
> This patch uses an entire page for each RX frag (whose default size is 20=
48).
> Consequently, on platforms like ppc64 where the default PAGE_SIZE is 64K,
> memory usage becomes very inefficient.
>=20
> Instead, I've tried a partial-page mapping scheme. This retains the
> page sharing logic, but un-maps each frag separately so that
> the data is copied from the bounce buffers.
[...]

You don't need to map/unmap each fragment separately; you can sync a
sub-page range with dma_sync_single_for_cpu().

Ben.

--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.

--=-MR9hj6n4gAEjeEVrTTDa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwgCROe/yOyVhhEJAQoDZA//Yb8io92i4VvRZHArMEEZkUYEK13fPs+f
+gj8fbkfIw0RYSr3KNxEncT5EmFfW1e+u8k3Av58JzjTTMNzbVej35bZufYBY0Zx
+2UuSmW+W6WulXHAojyGcxLTJv7v3zcApbTq0wcc5yt6lRPIR0tY5aHIvzOAnIfc
4JUpooN1nXmL7n2PtkR2/5zuAdqcKRfJ0L6tEDmMyKQZmOCdSiDRiL5ItTGMuNnD
vtC+u4sgp8rvduh5c3DXwthkdSCk1RMFJ9N3TFgYRrITxPoZT1W7P1uC51ji6mW6
nDz+9srEELc60/jnhhdsw/KRV+wc1JesuV4M+OaKuE7NGe5iq96ruh0Ea/xRGETt
mSzOTDgMwsYUSYLJN0EQsmi0gZ0cue6RSODcmL/9eHEiihgtG4IOWL5bxZvlVmwQ
/JI6eoFJeqWGNfxIurXadV+9SmS8jP/gfM8o2Hene/QgxwHOtpgB6YslGzW/ilf4
ZTPJHhcKnFX3GrxsacjTflI0E/wbZVYQYYlnvV4V2LqEq+L+8JInJB7s5R4ZwrDM
LdjtKaLUYxNRrqV03rF1rVdt+PNTlVS9iNKl8HKmkcntC+3iyr65Og1KMJ9YLvN+
sl77mIv+UdfD4B0wlHYY0QlsZl/CqQ4OUd0nQ4wLmRZOIaXbPcq9lIRsxrYhhH6y
WBkEcBJW0Cs=
=C7UZ
-----END PGP SIGNATURE-----

--=-MR9hj6n4gAEjeEVrTTDa--
