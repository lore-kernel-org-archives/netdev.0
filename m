From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Thu, 28 Mar 2013 16:04:20 +1100
Message-ID: <20130328160420.e57d7fdbd2894807e73e8497@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__28_Mar_2013_16_04_20_+1100_TGef+=DYYQ0ECeQT"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__28_Mar_2013_16_04_20_+1100_TGef+=DYYQ0ECeQT
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
ppc44x_defconfig) failed like this:

net/packet/af_packet.c: In function 'packet_sendmsg_spkt':
net/packet/af_packet.c:1515:2: error: implicit declaration of function 'skb=
_probe_transport_header' [-Werror=3Dimplicit-function-declaration]
drivers/net/tun.c: In function 'tun_get_user':
drivers/net/tun.c:1206:2: error: implicit declaration of function 'skb_prob=
e_transport_header' [-Werror=3Dimplicit-function-declaration]

Caused by commit 40893fd0fd4e ("net: switch to use
skb_probe_transport_header()").  This is a 32 bit build, so that
"BITS_PER_LONG > 32" is false and so NET_SKBUFF_DATA_USES_OFFSET is not
defined ... and skb_probe_transport_header() is only defined in an area of
skbuff.h protected by "#ifdef NET_SKBUFF_DATA_USES_OFFSET"  :-(

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__28_Mar_2013_16_04_20_+1100_TGef+=DYYQ0ECeQT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRU89UAAoJEECxmPOUX5FEn6IP/3vN6nDZpA0VF/AQ7P/rF31Q
gU1bYl40SHBe8Nmb+bZYGXXAdU2o2y7u52nR+rOQsnjlRL7V22BUyCVY/glpqIP8
82r0i5zCplZ+6cK+LqzFEy86//YSMivUi0Tu+rrmXMPsBtEAsQhV+oF50hSZIhn/
/4JpO8+M5IdxkjjWyhkaNJEVSzzgK0hazQ4ZRn5qL71YV7oC8fj9Zr035C1/0Iut
ns5Z1cnWOAbrBtmKz86tKPUAF1rtrGipKqnWetnEbDktV8eHw5H3xdZ11TRuzax8
LzcE3q/uIYA76D5qlqHbsPpIEZYMl+UmL1dTjgm/Gr0hrJPIZeBFRpx+bYHtT3tp
nozQrkVuQGVKbV6VOas0sFxo2AbQHLVM1ySQfkzy90oH52UCVYOJCsBCn9HeKl35
Fw7hPz1PS9+muexoVREH8O2VFDHZozCOMQe4e0JDQXi9V7K6PbcOKzV2xvVchXlh
Rhttok2fjkeqsFPLfn0yBx9414GEtZTpMr+ws1IG1xkAGcOLw0JOMOHiOhUD8C3q
Fi3Mghjr+01omQUlh7BIMbTObURLujsEb/nHX1trKNxQJy3vsmR7A4t6oHNOQq0p
zzqwoC0cB7VvhP4aM1wPerWyYnsysaUt4AjiPp77bLChRsJBiOCYGmqIVpEy7pMh
E5meeCUSWr0JviLofgNT
=a1zM
-----END PGP SIGNATURE-----

--Signature=_Thu__28_Mar_2013_16_04_20_+1100_TGef+=DYYQ0ECeQT--
