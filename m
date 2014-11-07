From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [Xen-devel] BUG in xennet_make_frags with paged skb data
Date: Fri, 07 Nov 2014 13:15:59 +0100
Message-ID: <545CB7FF.8080003@canonical.com>
References: <20141106214940.GD44162@ubuntu-hedt>	 <545C9013.1090406@linaro.org> <1415359320.13896.105.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="opLDNHQ8k3gaC4DnE7Cxm0op4Sxl5uidl"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Zoltan Kiss <zoltan.kiss@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415359320.13896.105.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--opLDNHQ8k3gaC4DnE7Cxm0op4Sxl5uidl
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 07.11.2014 12:22, Eric Dumazet wrote:
> On Fri, 2014-11-07 at 09:25 +0000, Zoltan Kiss wrote:
>=20
> Please do not top post.
>=20
>> Hi,
>>
>> AFAIK in this scenario your skb frag is wrong. The page pointer should=
=20
>> point to the original compound page (not a member of it), and offset=20
>> should be set accordingly.
>> For example, if your compound page is 16K (4 page), then the page=20
>> pointer should point to the first page, and if the data starts at the =

>> 3rd page, then offset should be >8K
>=20
> This is not accurate.
>=20
> This BUG_ON() is wrong.
>=20
> It should instead be :
>=20
> BUG_ON(len + offset > PAGE_SIZE<<compound_order(compound_head(page)));

would that not have to be

BUG_ON((page-compound_head(page)*PAGE_SIZE)+offset+len >
PAGE_SIZE<<compound_order(compound_head(page)));

since offset is adjusted to start from the tail page in that case.
>=20
> splice() code can generate such cases.
>=20
>=20



--opLDNHQ8k3gaC4DnE7Cxm0op4Sxl5uidl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJUXLf/AAoJEOhnXe7L7s6jwO4QANXShxZX4Btb/XdJqqqOkOyZ
5yU4K4RucnZCx3x6XZp2QCRtNLThkUeIjQJg5n8SbGrAUYIPceuECAN4HeMIPKDC
GcV/g/o4fy/rklSNaHx+ovZo4fr6vvK6ddN8kdh9S2wydD3z6oLpBIvpFAG5zj2a
YfLa/VZJl/YBGcl/NgW02z+XsNyAn0chwVVk5sQiHY/+dQpbSW9t2sF9fKmevAlN
mmY2K+nTFSE5+urKuNZWBkbBdz+hJayyociJlD6E3OWWa6211LV+ZtUhdzJAX+6C
Galm0Tx18tSg3+RDIZkodUgup6D4rpCxR385CmXSllFT3ZO+ZY2qa6bQD0qGPBR+
KFQ3W4N66auQ/onV0RwxCMCC6oj0yIldCYjq+gQPPeJG2VPiSLAyw8vdr5tQalzD
auqXimkvj/9CsRyihQLbkq7qrhv5zeqb7THLxJQlG2SkKuwwZMGTkV5P9F4rYPxO
1ZKGoXe+5lPJgO18haH2fKNztD/dsR4OkTk6QHausxzRmKIe8d2AIuwJsAwG4X+V
mts94bySYCUY9lJUd6sh8qVtTRShg3QV2GtzTyZ0sU0srSaZEJkpWjHRJ4vqKexF
ovRi8EU5Mt4svRVi3nasM3knvG8ZWsdsxQ57HHIR6fQiPiDuke+9VfCZYl4WePNF
rWCPML3R458kxlDrhr0A
=Jb9a
-----END PGP SIGNATURE-----

--opLDNHQ8k3gaC4DnE7Cxm0op4Sxl5uidl--
