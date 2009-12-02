From: Johannes Berg <johannes@sipsolutions.net>
Subject: tg3: not checking dma errors?
Date: Wed, 02 Dec 2009 15:01:06 +0100
Message-ID: <1259762466.32171.159.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-VhAQ789vf4kA2YxkXjv5"
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:40895 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754384AbZLBOBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 09:01:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VhAQ789vf4kA2YxkXjv5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I'm having some trouble with tg3 under memory pressure when it's
receiving lots of data, and so far this is the only thing I could find
-- unfortunately I can't capture the debug information on the machine --
netconsole obviously doesn't work, there's no serial and the output
doesn't fit on the screen...

So I figured I'd look at the code, and now I think there could be a bug
with mappings:

tg3_alloc_rx_skb:
...
        mapping =3D pci_map_single(tp->pdev, skb->data, skb_size,
                                 PCI_DMA_FROMDEVICE);

        map->skb =3D skb;
        pci_unmap_addr_set(map, mapping, mapping);

        if (src_map !=3D NULL)
                src_map->skb =3D NULL;

        desc->addr_hi =3D ((u64)mapping >> 32);
        desc->addr_lo =3D ((u64)mapping & 0xffffffff);

        return skb_size;



Shouldn't that check that 'mapping' is !=3D DMA_ERROR_CODE?

Similarly in tg3_run_loopback()?

johannes

--=-VhAQ789vf4kA2YxkXjv5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLFnMfAAoJEODzc/N7+Qmamn0QAI96e1qt7sPbiVRvPnA6HJYl
HSOkhUF8MQo+9Y/S2WzG/jOBCWvn9RFinQM+v+bUYCgKI16bVnZJRAsCXoBdU+8c
nIIGRzTxHy9rNVa1XGK+eDXe9ctOU+JiXr/fOuKxpUgaaFhxaBY+ldeyRvAgIp/E
/FOtOk3vmI8kY5AFJ4VPl1Spq1hcWsiauyBjVTc24qKSAihh07fEDpg0w5kl46Na
QF28piaWECHHbi2JbN/HCPZBrKu9AHFoMAi51w3Y5WXl1kYOIgOLIMi2lxdtwHoX
KLuSshdMfJAhCYboKxG9awHRWT3XuUbRP0QoBTK43o4acrRuOVHBmZm3bV9G+kGM
bEuZFFEoalwlV9a2nxCX2aghKwA/91xwL56ktXBwK2LvjMPSr/KhuM/29m83OdCn
h+sNZTcy1IY4+XaBin1pPEhdaTS3D4crX0aFwdb2yChg2IqWR2qPd87X/njHielW
hhKD9vrcYSHeCiua7setf6p+wm0ZBmSzExuTeaQuRGb9Ahz84Q133dl6jSLpbG++
QaRvJKnCPEBMzOvRv7vbShoxr7JkrqeHUUsMk2cvWZJMtxmWF2gX/GVBcreqUjQz
LnWzN+d/Ab5umQcMH4YOSQMeTm2F2q07ol5mwTtl5nbi1QR4MPTQ0nBdfGZl5+TP
Uo6VcqoKODQTAu7UEFiO
=5YZK
-----END PGP SIGNATURE-----

--=-VhAQ789vf4kA2YxkXjv5--

