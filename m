From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] net: i40e: fix shifting error in i40e_led_get
Date: Thu, 19 Dec 2013 14:04:36 -0800
Message-ID: <1387490676.2183.70.camel@jtkirshe-mobl>
References: <1387490237-27260-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1/b+AJKimcq7WHuWQJE3"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61772 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753547Ab3LSWFC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 17:05:02 -0500
In-Reply-To: <1387490237-27260-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1/b+AJKimcq7WHuWQJE3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-12-19 at 22:57 +0100, Daniel Borkmann wrote:
> In function i40e_led_get(), we fetch the LED mode from the GPIO
> registers and extract it from gpio_val. However, regardless of
> the outcome of the fetched value in gpio_val, the calculation
> to extract the mode will always be 0, as we do the following:
>=20
>   (gpio_val & (61440U /* 0xf << 12 */)) >> 17
>=20
> Instead of I40E_GLGEN_GPIO_CTL_INT_MODE_SHIFT, we need to use
> I40E_GLGEN_GPIO_CTL_LED_MODE_SHIFT to fix this.
>=20
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  Seems like this is still unfixed, so sending to netdev.
>=20
>  drivers/net/ethernet/intel/i40e/i40e_common.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Thanks Daniel, I may already have a patch in my queue that fixes this,
but if not, I will add this to my queue.

--=-1/b+AJKimcq7WHuWQJE3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSs210AAoJEOVv75VaS+3OCnEQAI7qaR5XMrzizYjZp2jvy4Ix
OGxsB1FNHx1CP77GbLFO37Xd1ViyzV5IFufRh/EpCyxqq8kT/zfbU56osQ6PFIKW
ii3v0+dQ5s3R185Idi6MtN/NRPZ2cDxHLn12+bnglNZX1vO6qjLbYs1m1BCAgRYz
C5QNn/odVmMhH2+opAq6b8T2MjGi8Ms6AQoDqK0+oAPzJ5opzOai8Fp4/zMG4GWM
T3JjNyrmewiOp9REAQVa33aRDEph7cwmX3+kGLriDZMCjQQgzhWpr7nXihHCOixk
4x2wh4nHaeCJhghP8B/HOUY7LOztc7YklHAoLJiG50+1pb7pFBSMp6ozw+WAq/Ta
WOvwY27gQ02B3pNiFXPGjnUpOQ1Cq9g3C4nuJ8Lcc55zcqIHZFGeRt41sTO7UcFs
BstVldrBPR9+TpN7GpKndgsGtB7IpR7bdamUW+YU2wmNaEuI0QBUF0gXqft66eH1
KGBYexo0VZKyH7YkneHwF9oEtnoS/CQVKI60ClOJk6A+Gd2awZWpSJD5uRR0WNA8
KGFXyNtyFD6UBQ/LyUTcp8i/U3b0DUPIpn+E8xrK6Yhs3I6k5eqsaejtr4fk4qkO
DcI2J5fXMwu606n3kw+3NH7boPauWsSdp6GjZIIoeUqd3bhs4H3ovS0hLfzN3L58
X5tzb7o49m3XXIFn6mm9
=pmB4
-----END PGP SIGNATURE-----

--=-1/b+AJKimcq7WHuWQJE3--
