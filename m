From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net V4 0/2] igb: ptp hardware clock
Date: Sun, 22 Jan 2012 19:57:24 -0800
Message-ID: <1327291044.2412.1.camel@jtkirshe-mobl>
References: <cover.1327161325.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Q8EWjUuzzPm3gkbpWWBy"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41529 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752572Ab2AWD5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jan 2012 22:57:38 -0500
In-Reply-To: <cover.1327161325.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Q8EWjUuzzPm3gkbpWWBy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2012-01-21 at 17:03 +0100, Richard Cochran wrote:
> * ChangeLog
> ** V4
>    - Use standard kernel cyclecounter/timecounter infrastructure
>      instead of a home grown counter overflow implementation.
> ** V3
>    - Driver compiles even without CONFIG_PTP_1588_CLOCK.
>    - Timestamping always works, even when PTP code missing or fails.
> ** V2
>    - Fixed wrong bit shifting in the 82576 code.
>    - Explained the timestamp locking with a comment in the code.
>    - Preserved the comments from the original timecompare implementation.
>    - Added an additional test within the overflow counter code to fix
>      a race condition. Details of the problem are given in the commit
>      message.
>=20
> This patch series implements a PHC driver for the Intel 82576 and
> 82580 devices, as part of the igb driver.  Only the base clock
> operations are implemented. The hardware does have some ancillary
> features, but these can be easily added later.
>=20
> The first patch adds the PHC driver code as a new source module but
> does not link it into the main igb driver. Because the system time
> counter is not so very wide, the code uses the overflow counter from
> the cyclecounter/timecounter code. Every read operation maintains the
> overflow counter, as does a "delayed work" watchdog.=20
>=20
> The second patch removes the timecompare code and links in the new
> functions.
>=20
> I have tested the 82580 with good results. However, I don't have the
> 82576 and so would appreciate testing and feedback.
>=20
> Thanks,
> Richard
>=20
>=20
> Richard Cochran (2):
>   igb: add PTP Hardware Clock code
>   igb: offer a PTP Hardware Clock instead of the timecompare method
>=20
>  drivers/net/ethernet/intel/igb/Makefile   |    2 +-
>  drivers/net/ethernet/intel/igb/igb.h      |   20 ++-
>  drivers/net/ethernet/intel/igb/igb_main.c |  167 +------------
>  drivers/net/ethernet/intel/igb/igb_ptp.c  |  388 +++++++++++++++++++++++=
++++++
>  4 files changed, 407 insertions(+), 170 deletions(-)
>  create mode 100644 drivers/net/ethernet/intel/igb/igb_ptp.c
>=20

Thanks Richard, I have added the patches to my queue.

--=-Q8EWjUuzzPm3gkbpWWBy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPHNqkAAoJEOVv75VaS+3OKYQP/j612Ly4v6UzZtZrM5sVRYVF
H4rQns+FIS0Bn8aXRXTYuA7emBNf/BsNBUfuqWch3VSNcCUxU4lBSLGt2qFGHBi2
uuyLVMmzWIjC0Rd5h4p9E21A4nuGChaFBLEEKBJAuDoaMWK5bKUcxAllopoKgsDE
Tk4i1aNY/GavzyVseMIAq3k9OyfREewdfsMlZjrp3b7jxBxxwUyv3AjQL4Xr0koo
K4TwgsoEQCBXJRGZCeqBZ+h1Fs0E7Ca6R0TgK8sdTTx9R9UwY1ocvLTKD7qT9uFU
2pjE6C7pUfd8GguBoltzmsyie8idJqarKtTw8poQs4zUniL1OZRx4lqwCGxAp773
b2Q00656QlwkvrNMaWVd5EbabGH5tt4EZ/PE86WIUgfYMSJvqBakJSpqOc+0ZTAU
G+Lmgq1gOW3TKV4lNqBcj9bgfw+9ttbvSDOgqHIhBCyx9il2J7T+ZTsUZsS5W2gu
OYSRdeWtOOySF/KN95g1nnsuDh5cY+bzngdZh3co97frFKvCxdiGPwIdLtP2Pp7T
quuO1eEiWUYk5Bg/6CHI8QRdN8mbMb+IBb9VxOuvDo4sBwCZ3JIivrYuZUJYCVeJ
4jNgu7IbjOjtX1qHX92ggfZLO1wOxPnLdlDCZd1xOuF+DWNdGlMGDhxb38Yb168s
EsPebQpEaOIr55QcVfXr
=HT//
-----END PGP SIGNATURE-----

--=-Q8EWjUuzzPm3gkbpWWBy--
