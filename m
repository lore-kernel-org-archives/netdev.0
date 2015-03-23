From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next V2 00/23] ptp: get ready for 2038
Date: Mon, 23 Mar 2015 03:16:30 -0700
Message-ID: <1427105790.2577.157.camel@jtkirshe-mobl>
References: <cover.1426973658.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SYxr+2Dm+3CEUIx8hr15"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Stefan =?ISO-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>,
	T
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1426973658.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-SYxr+2Dm+3CEUIx8hr15
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2015-03-21 at 22:39 +0100, Richard Cochran wrote:
> This series converts the core driver methods of the PTP Hardware Clock
> (PHC) subsystem to use the 64 bit version of the timespec structure,
> making the core API ready for the year 2038.
>=20
> In addition, I reviewed how each driver and device represents the time
> value at the hardware register level.  Most of the drivers are ready,
> but a few will need some work before the year 2038, as shown:
>=20
>    Patch   Driver
>    ------------------------------------------------
>    12      drivers/net/ethernet/intel/igb/igb_ptp.c
>    15 ?    drivers/net/ethernet/sfc/ptp.c
>    16      drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
>    18 ?    drivers/net/ethernet/tile/tilegx.c
>    19      drivers/net/phy/dp83640.c
>=20
> The commit log message documents how each driver is ready or why it is
> not ready.  For patches 15 and 18, I could not easily find out the
> hardware representation of the time value, so I would ask the
> maintainers for a review.
>=20
> Thanks,
> Richard
>=20
> * ChangeLog
> ** V2
>    - use the new methods in the posix clock code right away (patch #3)

The Intel driver changes look fine to me and as noted, more work appears
to be needed for igb.  It does not appear that Jake Jacobs got copied on
the patches, so I will make sure he takes a look at the changes for our
Intel drivers, since he did much of the work.

You get my ACK for the Intel changes.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

>=20
> Richard Cochran (23):
>   ptp: introduce get/set time methods with explicit 64 bit seconds.
>   ptp: use the 64 bit gettime method for the SYS_OFFSET ioctl.
>   ptp: use the 64 bit get/set time methods for the posix clock.
>   ptp: blackfin: convert to the 64 bit get/set time methods.
>   ptp: xgbe: convert to the 64 bit get/set time methods.
>   ptp: bnx2x: convert to the 64 bit get/set time methods.
>   ptp: tg3: convert to the 64 bit get/set time methods.
>   ptp: fec: convert to the 64 bit get/set time methods.
>   ptp: gianfar: convert to the 64 bit get/set time methods.
>   ptp: e1000e: convert to the 64 bit get/set time methods.
>   ptp: fm10k: convert to the 64 bit get/set time methods.
>   ptp: i40e: convert to the 64 bit get/set time methods.
>   ptp: igb: convert to the 64 bit get/set time methods.
>   ptp: ixgbe: convert to the 64 bit get/set time methods.
>   ptp: mlx4: convert to the 64 bit get/set time methods.
>   ptp: sfc: convert to the 64 bit get/set time methods.
>   ptp: stmmac: convert to the 64 bit get/set time methods.
>   ptp: cpts: convert to the 64 bit get/set time methods.
>   ptp: tilegx: convert to the 64 bit get/set time methods.
>   ptp: dp83640: convert to the 64 bit get/set time methods.
>   ptp: ixp46x: convert to the 64 bit get/set time methods.
>   ptp: pch: convert to the 64 bit get/set time methods.
>   ptp: remove 32 bit get/set methods.
>=20
>  drivers/net/ethernet/adi/bfin_mac.c              |    8 ++---
>  drivers/net/ethernet/amd/xgbe/xgbe-ptp.c         |   13 +++----
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    8 ++---
>  drivers/net/ethernet/broadcom/tg3.c              |   10 +++---
>  drivers/net/ethernet/freescale/fec_ptp.c         |    8 ++---
>  drivers/net/ethernet/freescale/gianfar_ptp.c     |   13 +++----
>  drivers/net/ethernet/intel/e1000e/ptp.c          |   16 ++++-----
>  drivers/net/ethernet/intel/fm10k/fm10k_ptp.c     |   12 +++----
>  drivers/net/ethernet/intel/i40e/i40e_ptp.c       |   26 +++++++-------
>  drivers/net/ethernet/intel/igb/igb_ptp.c         |   41 +++++++++++-----=
------
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     |   14 ++++----
>  drivers/net/ethernet/mellanox/mlx4/en_clock.c    |   11 +++---
>  drivers/net/ethernet/sfc/ptp.c                   |   22 ++++++------
>  drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c |    8 ++---
>  drivers/net/ethernet/ti/cpts.c                   |   12 +++----
>  drivers/net/ethernet/tile/tilegx.c               |   16 +++++----
>  drivers/net/phy/dp83640.c                        |   12 ++++---
>  drivers/ptp/ptp_chardev.c                        |    8 ++---
>  drivers/ptp/ptp_clock.c                          |   12 +++++--
>  drivers/ptp/ptp_ixp46x.c                         |    8 ++---
>  drivers/ptp/ptp_pch.c                            |    8 ++---
>  include/linux/ptp_clock_kernel.h                 |   12 +++----
>  22 files changed, 158 insertions(+), 140 deletions(-)
>=20



--=-SYxr+2Dm+3CEUIx8hr15
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVD+f+AAoJEOVv75VaS+3OXzgP/Aos11p97e9+vP5WTmESzgxm
6lchigfbixp2gqmJxBTFWnJxXJbW3Xmn+6KqHwucMpLp7BYDA5y3SJYYJpcCdB4m
L75SNFEORlNWZQUM+zuIH7JGg/QERwznUOinOQHE2KP/Nkif3WFG7vWLx8hSJiAV
sCNl5CvFaDrdBhcTnexahtGP+tofsW1NOiqiykaBi9+yHludjXXBGb/d8sfU68pH
wXC/PeKgk3dLn7kB+eOS8ImCMfZ9evO/+7oAnBSL9uRbQSWWVMZobqu3PREDoXaI
Lqb0r/nzYVrUMKr+4W2+GOESybxMwzBh+LDOSgvXEazZqVyztmbdU6fkpoPWEfTs
KyddVR+5BsRCdQaIDowVz2a4eRcbT0MR16BfL6SnX89ZZfYVuumnBomorzxO9In8
UxEsefamnzWfI+7TEwLv/P+3cfnrWllJv9G2GuU+86sA/6pIhK+xVptGEDxwQpm5
GMghH2PpS0CfftqFm/BTB41ODWHokto35+k2H6iitt2SxfkdDFurkWKj1c7wfxji
eU1eQJssLkCMOmlxcEqfzTuzodlvJV/n328iqkjlmS8/yUWVB6czRga9JE03DCGI
ioSVO/wIwCTrs88XojG1IStEHMPcVqJ0blRzeVZUIzJVozxy28m82g02jf/BuM9S
9CNfBR8pMMwwJslytwR/
=lJ2w
-----END PGP SIGNATURE-----

--=-SYxr+2Dm+3CEUIx8hr15--
