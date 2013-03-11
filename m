From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2013-03-11
Date: Mon, 11 Mar 2013 19:33:20 +0000
Message-ID: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-zzS/lk8bDeKqWKiuqAFL"
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>,
	scrum-linux <scrum-linux@solarflare.com>,
	Laurence Evans <levans@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49916 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754204Ab3CKTd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:33:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-zzS/lk8bDeKqWKiuqAFL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit 6906f4ed6f85b2d72fd944e15da6a905fdde8b40=
:

  htb: add HTB_DIRECT_QLEN attribute (2013-03-06 15:40:53 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit 1648a23fa159e5c433aac06dc5e0d9db36146016)

1. Merge sfc changes (only) accepted for 3.9.

2. PTP improvements from Laurence Evans.

3. Overhaul of RX buffer management:
- Always allocate pages, and enable scattering where possible
- Fit as many buffers as will fit into a page, rather than limiting to 2
- Introduce recycle rings to reduce the need for IOMMU mapping and
  unmapping

4. PCI error recovery (AER and EEH) implementation.

5. Fix a bug in RX filter replacement.

6. Fix configuration with 1 RX queue in the PF and multiple RX queues in
VFs.

Ben.

Alexandre Rames (2):
      sfc: Remove rx_alloc_method SKB
      sfc: Add AER and EEH support for Siena

Ben Hutchings (19):
      sfc: Disable soft interrupt handling during efx_device_detach_sync()
      sfc: Correct efx_rx_buffer::page_offset when EFX_PAGE_IP_ALIGN !=3D 0
      Merge branch 'sfc-3.9' into master
      sfc: Allow efx_channel_type::receive_skb() to reject a packet
      sfc: More sensible semantics for efx_filter_insert_filter() replace f=
lag
      sfc: Remove redundant parameter to efx_filter_search()
      sfc: Don't use efx_filter_{build,hash,increment}() for default MAC fi=
lters
      sfc: Merge efx_filter_search() into efx_filter_insert()
      sfc: Fix replacement detection in efx_filter_insert_filter()
      sfc: Disable RSS when using SR-IOV and only 1 RX queue on the PF
      sfc: Document current usage of efx_rx_buffer::len and efx_nic::rx_buf=
fer_len
      sfc: Properly distinguish RX buffer and DMA lengths
      sfc: Make RX queue descriptor counts unsigned for consistency
      sfc: Wrap __efx_rx_packet() with efx_rx_flush_packet()
      sfc: Replace efx_rx_buf_eh() with simpler efx_rx_buf_va()
      sfc: Explicitly prefetch RX hash prefix, not just Ethernet heade
      sfc: Update RX buffer address together with length
      sfc: Enable RX DMA scattering where possible
      sfc: Replace efx_rx_is_last_buffer() with a flag

Daniel Pieczko (2):
      sfc: reuse pages to avoid DMA mapping/unmapping costs
      sfc: allocate more RX buffers per page

Laurence Evans (2):
      sfc: PTP changes to support improved UUID filtering mode
      sfc: tidy up PTP synchronize function efx_ptp_process_times()

 drivers/net/ethernet/sfc/efx.c        |  268 ++++++++++--
 drivers/net/ethernet/sfc/efx.h        |   18 +-
 drivers/net/ethernet/sfc/enum.h       |   12 +-
 drivers/net/ethernet/sfc/ethtool.c    |    4 +-
 drivers/net/ethernet/sfc/falcon.c     |   17 +-
 drivers/net/ethernet/sfc/filter.c     |  249 ++++++++---
 drivers/net/ethernet/sfc/mcdi_pcol.h  |    1 +
 drivers/net/ethernet/sfc/net_driver.h |   97 +++--
 drivers/net/ethernet/sfc/nic.c        |   90 +++-
 drivers/net/ethernet/sfc/ptp.c        |  116 +++---
 drivers/net/ethernet/sfc/rx.c         |  793 +++++++++++++++++------------=
----
 drivers/net/ethernet/sfc/siena.c      |   25 +-
 12 files changed, 1072 insertions(+), 618 deletions(-)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-zzS/lk8bDeKqWKiuqAFL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQEcBAABCAAGBQJRPjGAAAoJEGkILBsOca60LcoIAKaCt8eObh6SvWKkSEUBqNmz
b0woKJ95HucqJ6YREcqNghe3Kg9PSHIIxOt/IuXh1F0setVWDVYObh0bqlszeoce
pWIq8jueboZy/pATRrqZr7IqRKyPzfXQabl2GG6V9UC+3KC+siahleLMNxbImSFX
h1xpNJe42j6Wur29WEJWX7TBqCIffVY+kCnKw6aovOAyk/SMtiNmisWmdPf379RY
Uy4TO3dftYZtvBVtC/3gl5qP+lGtOicwzikbZRmDiRXt6tHro4xKx5jEUP28TtoL
20CIRHcqc//nwL3iifntGnznB4K3zNtQU9/BnpWF1xi6n/SL5N6j6Sz5IJoB1t4=
=sa4m
-----END PGP SIGNATURE-----

--=-zzS/lk8bDeKqWKiuqAFL--
