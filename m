From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
Date: Tue, 11 Oct 2016 14:17:51 -0400
Message-ID: <073e0007-a43b-134d-ba7e-b290304be585@redhat.com>
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
 <20161011173216.GA16892@obsidianresearch.com>
 <22f61258-9bcf-0adc-f23f-79a4f1d50c6a@redhat.com>
 <20161011180119.GB17319@obsidianresearch.com>
 <1476209407.448.9.camel@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="RhJt5xFavpXih7o5L1bhEsHnwbkjdDjAl"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476209407.448.9.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--RhJt5xFavpXih7o5L1bhEsHnwbkjdDjAl
Content-Type: multipart/mixed; boundary="iQict26tIwJVPd4LqVnqfwBSq1A7Gx8qV";
 protected-headers="v1"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <073e0007-a43b-134d-ba7e-b290304be585-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 <20161011173216.GA16892-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
 <22f61258-9bcf-0adc-f23f-79a4f1d50c6a-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 <20161011180119.GB17319-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
 <1476209407.448.9.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <1476209407.448.9.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

--iQict26tIwJVPd4LqVnqfwBSq1A7Gx8qV
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/11/2016 2:10 PM, Paolo Abeni wrote:
> On Tue, 2016-10-11 at 12:01 -0600, Jason Gunthorpe wrote:
>>> AFAICS the max mtu is already underlying h/w dependent, how does such=

>>> differences are currently coped by ? (I'm sorry I lack some/a lot of =
IB
>>> back-ground)
>>
>> It isn't h/w dependent. In CM mode the MTU is 65520 because that is
>> what is hard coded into the ipoib driver. We tell everyone to use that=

>> number. Eg see RH's docs on the subject:
>>
>> https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux=
/7/html/Networking_Guide/sec-Configuring_IPoIB.html
>>
>> AFAIK, today everyone just wires that number into their scripts, so we=

>> have to mass change everything to the smaller number.

Well, not exactly.  Even if we put 65520 into the scripts, the kernel
will silently drop it down to 65504.  It actually won't require anyone
change anything, they just won't get the full value.  I experimented
with this in the past for other reasons and an overly large MTU setting
just resulted in the max MTU.  I don't know if that's changed, but if it
still works that way, this is much less of an issue than it might
otherwise be.

>> That sounds
>> really hard, IMHO if there is any way to avoid it we should, even if
>> it is a little costly.
>=20
> Thank you for the details!
>=20
> The first s/g fragment (the head buffer) is not allocated with the page=

> allocator, so perhaps there is some not too difficult/costly way out of=

> this.
>=20
>=20
>=20
>=20
>=20
>=20


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG Key ID: 0E572FDD


--iQict26tIwJVPd4LqVnqfwBSq1A7Gx8qV--

--RhJt5xFavpXih7o5L1bhEsHnwbkjdDjAl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJX/SzPAAoJELgmozMOVy/dbmgP/3GTgoz4ZUdxyu22VvL4tMmR
5X//7rMIVXVj4KpfsvhghvjfhVmDaOAFEC5xrpSL+xMSGdjRNdjf0spVXzo0lFvj
Kh7lUKSHNKd8UVhaR/HVLs18tiv7EZPfBJqr1tYfKT3VirdEhwNhZ51mY05fN0ZH
GgK4pvhPJwdJp2evQtbXNU4XCGLHN6ILgbQvFzije9TMgewrEFBgiqDS8YLNIX4n
BruoPMCW4bUpaE5GysGC5S7nTO3XgAtCVa8UtXsbFxJ0E/yRJZsgFM0Eb2mKWH4w
jLLZPCUJfRrZ6e/s5Dz+hp6QpBZ6vF1TMTcNIkMfkXyUWgoYQVfEs5/8Rt2qKVnR
VWT+zrsHABr4m4Qzt22eaEoragrFSEPWXJnk3AS9sWZrGQRQKKDUX1nwpdwH0sMH
fBdFXKLWn7acmQJOYm12NlfUM7rvcHSP0+1GJymMWZx7I2m1VzFW5p98ruh208gv
x1gLt9CRkUvyt3aAzILOk9JFx3pwILQZANspNPLve93pPivzaNEsFSk5+GZVJ9iK
R/ckWK3Wb0zc916rgGpHqtso3IvMK2dX4yQA+KQF3YnnZbrACk9ZYENhXCGNn+aG
rB7IWUnmoLRLDUd3jztMHynCWmJVIAGNrfpI8OTK059QQc/SH59hTZluwq5DxQBf
uZ6qDglEvaSzDe9PFf4b
=FFxA
-----END PGP SIGNATURE-----

--RhJt5xFavpXih7o5L1bhEsHnwbkjdDjAl--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
