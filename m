From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next V2 0/2] igb: ptp hardware clock
Date: Mon, 02 Jan 2012 17:20:47 -0800
Message-ID: <1325553647.2428.4.camel@jtkirshe-mobl>
References: <cover.1324901880.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-agj5KQpfZ9cZCfoKe5vy"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40839 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750753Ab2ACBUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jan 2012 20:20:49 -0500
In-Reply-To: <cover.1324901880.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-agj5KQpfZ9cZCfoKe5vy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-12-26 at 13:26 +0100, Richard Cochran wrote:
> * ChangeLog V2
>    - Fixed wrong bit shifting in the 82576 code.
>    - Explained the timestamp locking with a comment in the code.
>    - Preserved the comments from the original timecompare implementation.
>    - Added an additional test within the overflow counter code to fix
>      a race condition. Details of the problem are given in the commit
>      message.
>=20
> This patch series implements a PHC driver for the Intel 82576 and
> 82580 devices, as part of the igb driver.
>=20
> The first patch adds the PHC driver code as a new source module but
> does not link it into the main igb driver. Because the system time
> counter is not so very wide, the code implements an overflow counter
> in software. Every read operation maintains the overflow counter, as
> does a "delayed work" watchdog. Only the base clock operations are
> implemented. The hardware does have some ancillary features, but these
> can be easily added later.
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
>  drivers/net/ethernet/intel/igb/igb.h      |   21 +-
>  drivers/net/ethernet/intel/igb/igb_main.c |  167 +----------
>  drivers/net/ethernet/intel/igb/igb_ptp.c  |  486 +++++++++++++++++++++++=
++++++
>  4 files changed, 505 insertions(+), 171 deletions(-)
>  create mode 100644 drivers/net/ethernet/intel/igb/igb_ptp.c
>=20

We found an issue with this series of patches, if we did not have
CONFIG_PTP_1588_CLOCK enabled in the kernel, the igb driver would not
compile.

So I would suggest wrapping the portions of code with #ifdef
CONFIG_PTP_1588_CLOCK.

I will await v3 of the series, thanks Richard for this work!

--=-agj5KQpfZ9cZCfoKe5vy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPAlfvAAoJEOVv75VaS+3O0qkP+wSatRhgmPJgHfdiTdP7W0Jr
xYUsaUIkECzvW3nbPg7hceeANYI0lENT4GEU2pzHrOu6/Ql3EiIjgpkGoGtTxhKg
aGQdhMAL0pxMKCoRMHJEDjw0d4jwKDgoVWiAmCPdV/Brig8FPCkVkJaZGpC/LQ+O
AGQ11CiUmPRlYjI96f7eBWVDwd8Tgqx3K7zkE5LwcCMPfVL30pEV73gqpAobyFjr
CW4PDeLW4Rf9vMBd9llq3iFKBQuEY0Tw9LNxYk/mFIYqNCsWyEtzM6vk/biIBWvR
SM9/9/ag641duf9zMdJp4OzCkK7nBXN1XOw91mTngDJu1Nhv9QoqC+tbuluuDlIU
CedGjijf776RtILJ+NtpY55DFmxs2jtNtn7YPphz66eY6j4sgmk926QwFflgmkLu
T+QRPlWIftvolibKQewWIvdKcDMqCujg5TBnrCkTd6U3sMS9VUScuXnRKb8iEUOl
0GxDmGpYdPxC2vWF/2fd8Udm3r727lCWvPEGnfVHj1ySSy7f1hhtb5VhexNEQIXh
lvOZhnohPh1AQj21jkXkDaLG6jgd0LpfBTD80e8ZSyj3cwMHGgPRS2iejqrdC7Ad
BP10K6i5+mtWMCTQ4TSO5FvL7u0BnpKb0dGEsg+4fVhaTnqPyF2tbclJzCPssFpO
Tx1flukfksGEkezYJk4c
=K7EE
-----END PGP SIGNATURE-----

--=-agj5KQpfZ9cZCfoKe5vy--
