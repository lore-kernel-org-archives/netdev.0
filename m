From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
Date: Thu, 13 Oct 2016 10:35:35 -0400
Message-ID: <20ace6ee-b9e4-073c-56e7-29b2c50ae2d5@redhat.com>
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
 <20161013.102432.1450901395774429343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="JGx243VvOtSLHpb0UOp8083dd4Iq89CQE"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161013.102432.1450901395774429343.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--JGx243VvOtSLHpb0UOp8083dd4Iq89CQE
Content-Type: multipart/mixed; boundary="wpOgXTRGAv9lkFA9116guVSs2WWKRI0ib";
 protected-headers="v1"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <20ace6ee-b9e4-073c-56e7-29b2c50ae2d5-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 <20161013.102432.1450901395774429343.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
In-Reply-To: <20161013.102432.1450901395774429343.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

--wpOgXTRGAv9lkFA9116guVSs2WWKRI0ib
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 10/13/2016 10:24 AM, David Miller wrote:
> From: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date: Tue, 11 Oct 2016 19:15:44 +0200
>=20
>> After the commit 9207f9d45b0a ("net: preserve IP control block
>> during GSO segmentation"), the GSO CB and the IPoIB CB conflict.
>> That destroy the IPoIB address information cached there,
>> causing a severe performance regression, as better described here:
>>
>> http://marc.info/?l=3Dlinux-kernel&m=3D146787279825501&w=3D2
>>
>> This change moves the data cached by the IPoIB driver from the
>> skb control lock into the IPoIB hard header, as done before
>> the commit 936d7de3d736 ("IPoIB: Stop lying about hard_header_len
>> and use skb->cb to stash LL addresses").
>> In order to avoid GRO issue, on packet reception, the IPoIB driver
>> stash into the skb a dummy pseudo header, so that the received
>> packets have actually a hard header matching the declared length.
>> Also the connected mode maximum mtu is reduced by 16 bytes to
>> cope with the increased hard header len.
>>
>> After this commit, IPoIB performances are back to pre-regression
>> value.
>>
>> Fixes: 9207f9d45b0a ("net: preserve IP control block during GSO segmen=
tation")
>> Signed-off-by: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>=20
> Not providing an accurate hard_header_len causes many problems.
>=20
> In fact we recently fixed the mlxsw driver to stop doing this.
>=20

Sure, but there are too many users of the cb struct, and whatever
problems you are saying there are by lying about the hard header len are
dwarfed by the problems caused by the inability to store the ll address
anywhere between hard_header and send time.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG Key ID: 0E572FDD


--wpOgXTRGAv9lkFA9116guVSs2WWKRI0ib--

--JGx243VvOtSLHpb0UOp8083dd4Iq89CQE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJX/5u3AAoJELgmozMOVy/dTNYQAK6D4QGURvHk9k9vb5aMyA0y
bfJAenqYyeRj3IoUtLj2s29Pt7ACTGfFMGDRlLZYT4qDgFb+tPCz5vrcPWxOf/mq
cMx8nDKlCJe2NIobz3IVlCi4RGmpkRfYkZAOeOjC9LaK7NMXiZx++xHPw5hQw1Ia
Lru+o/UyLGQkSN3B2eOoty7w2pkYCOUm+xOugT28pn9LGJesoTeALKyL0kQAqspJ
3KWlJC4JmrLL5hVmgDyEluNCL40ibt7uUymlnUpgObvkrdCCFdBtCIUnLTUCd6mg
W6dgflyyWBnRNrRcPDHY/ZF9GRFzKVZIbZzZ4TzcA0HUUNrcQZScttlXD9RegJU+
1Ic863C9vrC2kM37Q79V2VIyXabhrfEVdr5Ne16ZLLsYIFrCvkrodWxUyLJAlKaj
i4+KHeQun6Lho0yCTjDSclSAh6+h4rEWb0DP/sQTVpvllF621jWruJMG9lmFPqh1
Ki2P+uoE9zMfEpGLSwNXVK2NztZQi4fsxo9eoKiiIhWqefdbw0Na1mKUdt5blezX
wVItfch6vqG7QPf0OGAR3g0VG3nht2ND9Le27ZLSxZsoYzpmuHzsY0u5eWkEHTZz
WskWBKAX5WwnLs7I/E9eh+9q5rMHvmmExZwZ27kxhDQriPuTN+IBbZtbNdvlS6f4
FUnJcS/D/sJNARhJJYbk
=uhax
-----END PGP SIGNATURE-----

--JGx243VvOtSLHpb0UOp8083dd4Iq89CQE--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
