From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc 2013-12-10
Date: Wed, 11 Dec 2013 01:51:54 +0000
Message-ID: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-2xAJZYy0f/ZpQE54eyvv"
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:40882 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab3LKBwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 20:52:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-2xAJZYy0f/ZpQE54eyvv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit e1ca87bb1b64b044163e686ff3bb71405156c561=
:

  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git=
/linville/wireless (2013-12-05 16:02:56 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.13

for you to fetch changes up to 6b294b8efedaa7cf7507154148e2c79766ad6f96:

  sfc: Poll for MCDI completion once before timeout occurs (2013-12-06 22:2=
7:55 +0000)

Several fixes for the PTP hardware support added in 3.7:
1. Fix filtering of PTP packets on the TX path to be robust against bad
header lengths.
2. Limit logging on the RX path in case of a PTP packet flood, partly
from Laurence Evans.
3. Disable PTP hardware when the interface is down so that we don't
receive RX timestamp events, from Alexandre Rames.
4. Maintain clock frequency adjustment when a time offset is applied.

Also fixes for the SFC9100 family support added in 3.12:
5. Take the RX prefix length into account when applying NET_IP_ALIGN,
from Andrew Rybchenko.
6. Work around a bug that breaks communication between the driver and
firmware, from Robert Stonehouse.

Please also queue these up for the appropriate stable branches.

Ben.

----------------------------------------------------------------
Alexandre Rames (1):
      sfc: Stop/re-start PTP when stopping/starting the datapath.

Andrew Rybchenko (1):
      sfc: RX buffer allocation takes prefix size into account in IP header=
 alignment

Ben Hutchings (3):
      sfc: Add length checks to efx_xmit_with_hwtstamp() and efx_ptp_is_ptp=
_tx()
      sfc: Rate-limit log message for PTP packets without a matching timest=
amp event
      sfc: Maintain current frequency adjustment when applying a time offse=
t

Laurence Evans (1):
      sfc: PTP: Moderate log message on event queue overflow

Robert Stonehouse (2):
      sfc: Refactor efx_mcdi_poll() by introducing efx_mcdi_poll_once()
      sfc: Poll for MCDI completion once before timeout occurs

 drivers/net/ethernet/sfc/efx.c        |  8 ++++-
 drivers/net/ethernet/sfc/mcdi.c       | 39 +++++++++++++++------
 drivers/net/ethernet/sfc/net_driver.h |  3 ++
 drivers/net/ethernet/sfc/nic.h        |  2 ++
 drivers/net/ethernet/sfc/ptp.c        | 66 ++++++++++++++++++++++++++++++-=
----
 drivers/net/ethernet/sfc/rx.c         |  6 ++--
 6 files changed, 101 insertions(+), 23 deletions(-)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-2xAJZYy0f/ZpQE54eyvv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQEcBAABCAAGBQJSp8U6AAoJEGkILBsOca60aIIH+gOK6L7WxLUQndzAZuJUeWia
H317jagEIrlYZjffEQNZDvnF1urMJC7LPDECTvtxnW1Y5daosyE5x1rvbXMyvQzN
iBo8T+8axcN2ZPlACobjolPrAVeVML9doLJ89Wc09KyFF2kl1zP/kPCWPLsuKo7w
kQDbhmfI5wZLw+6Z2mnGALUDV/FrZNwpAU+xOVWs5lZAmDaxFvntMPi8TKvpJsZh
noMk0zURuZc2FlX7KCpvhxF9U4ZB1g4xbxbmaaArga/3mH1VPkoXKnkWKZTlRSnh
T40jj/DMRqwqVXn0Zt8fqDZN/2j/pcp0A9WwiBGdcSy4/lINwvKw2iXEQGtD+D8=
=+MIB
-----END PGP SIGNATURE-----

--=-2xAJZYy0f/ZpQE54eyvv--
