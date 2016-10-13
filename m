From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header,Re: [PATCH] IB/ipoib: move back the IB LL address into the hard header
Date: Thu, 13 Oct 2016 11:20:59 -0400
Message-ID: <2eadc083-e2e0-5c6d-fe84-c5851be3e2ec@redhat.com>
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
 <20161013.102432.1450901395774429343.davem@davemloft.net>
 <20ace6ee-b9e4-073c-56e7-29b2c50ae2d5@redhat.com>
 <20161013.104314.1842951254979604965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="x0c4Kd7uRsuLi9gjCeWhxkiHJv8KMtKWu"
Cc: pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161013.104314.1842951254979604965.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--x0c4Kd7uRsuLi9gjCeWhxkiHJv8KMtKWu
Content-Type: multipart/mixed; boundary="UgukTDxGu9ljfjNIfdjLkDSpAP0j04wC0";
 protected-headers="v1"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <2eadc083-e2e0-5c6d-fe84-c5851be3e2ec-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header,Re: [PATCH] IB/ipoib: move back the IB LL address into the hard header
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 <20161013.102432.1450901395774429343.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
 <20ace6ee-b9e4-073c-56e7-29b2c50ae2d5-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 <20161013.104314.1842951254979604965.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
In-Reply-To: <20161013.104314.1842951254979604965.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

--UgukTDxGu9ljfjNIfdjLkDSpAP0j04wC0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 10/13/2016 10:43 AM, David Miller wrote:
> From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date: Thu, 13 Oct 2016 10:35:35 -0400
>=20
>> On 10/13/2016 10:24 AM, David Miller wrote:
>>> From: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>> Date: Tue, 11 Oct 2016 19:15:44 +0200
>>>
>>>> After the commit 9207f9d45b0a ("net: preserve IP control block
>>>> during GSO segmentation"), the GSO CB and the IPoIB CB conflict.
>>>> That destroy the IPoIB address information cached there,
>>>> causing a severe performance regression, as better described here:
>>>>
>>>> http://marc.info/?l=3Dlinux-kernel&m=3D146787279825501&w=3D2
>>>>
>>>> This change moves the data cached by the IPoIB driver from the
>>>> skb control lock into the IPoIB hard header, as done before
>>>> the commit 936d7de3d736 ("IPoIB: Stop lying about hard_header_len
>>>> and use skb->cb to stash LL addresses").
>>>> In order to avoid GRO issue, on packet reception, the IPoIB driver
>>>> stash into the skb a dummy pseudo header, so that the received
>>>> packets have actually a hard header matching the declared length.
>>>> Also the connected mode maximum mtu is reduced by 16 bytes to
>>>> cope with the increased hard header len.
>>>>
>>>> After this commit, IPoIB performances are back to pre-regression
>>>> value.
>>>>
>>>> Fixes: 9207f9d45b0a ("net: preserve IP control block during GSO segm=
entation")
>>>> Signed-off-by: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>>
>>> Not providing an accurate hard_header_len causes many problems.
>>>
>>> In fact we recently fixed the mlxsw driver to stop doing this.
>>>
>>
>> Sure, but there are too many users of the cb struct, and whatever
>> problems you are saying there are by lying about the hard header len a=
re
>> dwarfed by the problems caused by the inability to store the ll addres=
s
>> anywhere between hard_header and send time.
>=20
> IB wants to pass addressing information between layers, it needs to
> find a safe way to do that.

We *had* a safe way to do that.  It got broken.  What about increasing
the size of skb->cb?  Or adding a skb->dgid that is a
u8[INFINIBAND_ALEN]?  Or a more generic skb->dest_ll_addr that is sized
to hold the dest address for any link layer?

> Pushing metadata before the head of the SKB data pointer is illegal,
> as the layers in between might want to push protocol headers,

That's a total non-issue for us.  There are no headers that protocols
can add before ours.

> mirror
> the packet to another interface

Doesn't that then mean that the headers specific to this interface
should be stripped before the mirror?  If so, I believe the way Paolo
did this patch, that is what will be done.

>, etc.
>=20
> So this "metadata in SKB data" approach is buggy too.




--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG Key ID: 0E572FDD


--UgukTDxGu9ljfjNIfdjLkDSpAP0j04wC0--

--x0c4Kd7uRsuLi9gjCeWhxkiHJv8KMtKWu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJX/6ZbAAoJELgmozMOVy/dvT8P/2LGTW6lHAkvoqGNdhHVRtBb
zM6dwUUT1OT3oo4WLnZADWp+0oYQ7Wg/p9V/87owBs83CeBKdMHo4rlc6kc2fdmc
npxIGWPEP0590l+TJDbhambETT7bCXlrzJgLd3Rjw/bE8HwDEAg+yjdO6xKG65nG
sJ3JbWlx/vEAwYaRdJVG6Lv9jMoWPFNMhRyVBJpfSJ3Di4ye9lmqnogTnZhRBVco
W10/dha6wHjFSTo4q5iukfNBl10pJ30hsHiXUa4AyEKB8vksMhCOKC4FazfcdvHW
fm0kLzz5d7C/qX+hUMlrlGNkGpt50QQV/72ExUBxEgiC4TFvzIOjmOkIIyzJu65N
ZrHxqU5BNK5nNnvDgPF7V4DbO87OWU/GpMSA5O1aNUD94Puvs2S0aff8LiT6rBc6
Giw1lHWJVDOOIg3WxJ61R7p0t28KaB2kVzT9guKtgf1sQst72UO0/AkgDx04Dm3a
Ho5w4L0pPC2zZhroP4CIDcM/j5cz99AoDRC1ufvDNg9Nz0G8nV6tXoV4H44BWTHC
l3lHmeCLof72I+o78SoTe3mZnwmERs3HwUlmS/pBrJcqZzW196l4vn35HjBPlC7B
5lVGGgBWxoHb8tyHA0M+PZen0ybDpC/1vRJ+lCACwGFgZL+unt/jSMj2kAJ8EAdt
VtBgL6KtgACWDZdzSdnH
=1IZb
-----END PGP SIGNATURE-----

--x0c4Kd7uRsuLi9gjCeWhxkiHJv8KMtKWu--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
