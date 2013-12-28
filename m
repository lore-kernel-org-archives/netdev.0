From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: avoid potential deadlock in
 e1000_do_[read|write]_eeprom()
Date: Sat, 28 Dec 2013 06:12:43 -0800
Message-ID: <1388239963.2183.199.camel@jtkirshe-mobl>
References: <1387578320-26525-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2236661024331581644=="
Cc: ldv-project@linuxtesting.org, Don, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Ronciak <john.ronciak@intel.com>,
	netdev@vger.kernel.org, John
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1387578320-26525-1-git-send-email-khoroshilov@ispras.ru>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============2236661024331581644==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1bQbz9DGiNyyGFHjJP0a"


--=-1bQbz9DGiNyyGFHjJP0a
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-12-21 at 02:25 +0400, Alexey Khoroshilov wrote:
> If eeprom->word_size is zero, e1000_do_[read|write]_eeprom() invoke
> e1000_init_eeprom_params() to reinit eeprom params.
> That is not a good idea since e1000_init_eeprom_params() calls
> e1000_read_eeprom() if eeprom->type is e1000_eeprom_spi.
> That means a deadlock on e1000_eeprom_lock.
>=20
> At the same time it is unclear if the reinit is needed at all.
> e1000_init_eeprom_params() is called from probe, so
> it should succeed before any activities of the module start.
>=20
> The patch suggests to remove the try to reinit eeprom params.
>=20
> Found by Linux Driver Verification project (linuxtesting.org).
>=20
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_hw.c | 8 --------
>  1 file changed, 8 deletions(-)

Sorry Alexey for the late reply, I thought I had responded to you
earlier.

I have added your patch to my queue.  Thanks!

--=-1bQbz9DGiNyyGFHjJP0a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSvtxbAAoJEOVv75VaS+3OSwsP/jzM/m9ES1wuTgrrPZwdVjGH
gHGG7w2XjGVJT2HNw+eI+oaooh0Krjse4AHCvpkCLIZJspN/j+HfCDSctz4uJsb+
TkYwWja7AHscriQDPd+OlNZbuB8ECnHmVpLHqj0A7XczfyE+TJbgC50tD5ps3hX5
F6aTrP+pftPKALSmfc7FxD5w4q1OztqnpF2NCtE8pxM0KprWhdrVYJ3b/+u31B/d
BMdHhFVwiqAByQ0R7RGaFDJ+g6t3lx3A/yt46y2RHbR1MVMAFIk+EU0G9Yw5BkD3
P9VECr4Evo3F07ll8EfSYUzjv8FONGnd3CpeNZAnIiXeJqOugqS1yedifU3Nvoy/
BmcJz63k/8zDq/8uaz9V9adeIzYE67KmNsXhseMlvjpJ8UVghocxXp6267KbUUVT
nKqWCmWvQ2gNH/Bu/yMzKGpBzqVWEPvASHs4pdfWnHf2Vnm32fWtQx7XyP/3M+8f
Y+bYSF/TGSi9Bf7zfJLMuD8IaRTazA23R6KlP3DqoElWT0X9dhRLIhAO5iX6Ail8
G8JlZ1roGbZdCmdMavAFvTMhxP6ZXMZ31gG/oPANyewGFf5GT0lNvmFUXR6CHAIE
D99PsgOL7tb479wllFZg+hQ8LN/2r/uY/E+F3iA+71e9Z30gZQF81BD3KK2AM4jC
w5TI6izAvUXVE0Ag96z/
=LBVT
-----END PGP SIGNATURE-----

--=-1bQbz9DGiNyyGFHjJP0a--



--===============2236661024331581644==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
--===============2236661024331581644==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============2236661024331581644==--
