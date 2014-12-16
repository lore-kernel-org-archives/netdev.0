From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/5] e1000e: reset MAC-PHY interconnect on 82577/82578
Date: Tue, 16 Dec 2014 04:12:06 -0800
Message-ID: <1418731926.2467.15.camel@jtkirshe-mobl>
References: <1418725700-31465-1-git-send-email-Yanjun.Zhu@windriver.com>
	 <1418725700-31465-2-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-WNfMXFYqBeKzLwVwwjBV"
Cc: netdev@vger.kernel.org, w@1wt.eu,
	Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Zhu Yanjun <zyjzyj2000@gmail.com>, stable <stable@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1418725700-31465-2-git-send-email-Yanjun.Zhu@windriver.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-WNfMXFYqBeKzLwVwwjBV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-12-16 at 18:28 +0800, Zhu Yanjun wrote:
> 2.6.x kernels require a similar logic change as commit 6dfaa76=20
> [e1000e: reset MAC-PHY interconnect on 82577/82578] introduces
> for newer kernels.
>=20
> During Sx->S0 transitions, the interconnect between the MAC and PHY on
> 82577/82578 can remain in SMBus mode instead of transitioning to the
> PCIe-like mode required during normal operation.  Toggling the
> LANPHYPC
> Value bit essentially resets the interconnect forcing it to the
> correct
> mode.
>=20
> after review of all intel drivers, found several instances where
> drivers had the incorrect pattern of:
> memory mapped write();
> delay();
>=20
> which should always be:
> memory mapped write();
> write flush(); /* aka memory mapped read */
> delay();
>=20
> explanation:
> The reason for including the flush is that writes can be held
> (posted) in PCI/PCIe bridges, but the read always has to complete
> synchronously and therefore has to flush all pending writes to a
> device.  If a write is held and followed by a delay, the delay
> means nothing because the write may not have reached hardware
> (maybe even not until the next read)
>=20
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
> ---
>  drivers/net/e1000e/defines.h |  2 ++
>  drivers/net/e1000e/ich8lan.c | 20 ++++++++++++++++++++
>  2 files changed, 22 insertions(+)

To be clear, Zhu is wanting this applied to stable trees (yet did not CC
stable@vger.kernel.org ).

Willy- I am fine with this series being applied to stable.

--=-WNfMXFYqBeKzLwVwwjBV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUkCGWAAoJEOVv75VaS+3OJt4P/2gzZN/sLW9DrG7B04XFbKVZ
2oiJyImUtDy4gSj1aaiQL/c5cAu72pLyBSWGWlzT5Q2UFMjNpPK655ED1RE+EwqC
b0r2kBhODgWIRCbSUvObS639kYvSkGDTM3TXAe5HW7ciLwwLQcnPAxoVXlAm4r+j
6zN/1EVx4Sm+IgikU+qerIZXynhq/q36EJNDHhs2m0OQjJ8bZSVfXz4VSPwOET5t
IrtjW14lblAgWmI64kMJ172sd6rrhEc99kYlq6sdxNU3d3BQiwXyx/+ztnXVxd1b
D7s3DHSTKY9BdGxDDNNRCbpBoYqO39oFt9VmwVt7MJiT2fSBXSV1Jx7Y1j3qWvnb
zmv66f6lYnyz4BRAT9QrN6DscftipSb2ALiUUnQUCZjh++ngfol0Yao4UKa9nxzH
Fk56cxK1XWuLWVPArNqheEKMstBilri6savbUCZvsJV3wAEMkMzxus1V+RvY70z/
Rx4DtTxK1befqlkZqQy7FmnlddDWy1MDXPOsxNFnnpTIzojj9RbSsWA1U2LAfxH4
AR7f1YaFfJTchx42TBJPrzh39h6pVpZpAgHps5xfnyz5uSQhKR+sAeu1E+nAptCc
fOu9LGhFHwQ261dqJZxCQdUNLGduyNRfwuTRWqEyBmc7NHtjJ3GyIzjacynXdoGi
jT8wdDYKsqit3OAt1JjX
=jAX/
-----END PGP SIGNATURE-----

--=-WNfMXFYqBeKzLwVwwjBV--
