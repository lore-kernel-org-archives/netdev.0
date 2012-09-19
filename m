From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2012-09-19
Date: Wed, 19 Sep 2012 20:09:35 +0100
Message-ID: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	Rodolfo Giometti <giometti@enneenne.com>,
	linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Andrew Jackson <ajackson@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:58271 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754601Ab2ISTJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:09:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit b4516a288e71c64d7e214902250baf78b7b3cdcf:

  llc: Remove stray reference to sysctl_llc_station_ack_timeout. (2012-09-17 13:13:24 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit 450783747f42dfa3883920acfad4acdd93ce69af)

1. Extension to PPS/PTP to allow for PHC devices where pulses are
   subject to a variable but measurable delay.
2. PPS/PTP/PHC support for Solarflare boards with a timestamping 
   peripheral.
3. MTD support for updating the timestamping peripheral on those boards.
4. Fix for potential over-length requests to firmware.

Ben.

Ben Hutchings (7):
      pps/ptp: Allow PHC devices to adjust PPS events for known delay
      sfc: Fix maximum array sizes for various MCDI commands
      sfc: Convert firmware subtypes to native byte order in efx_mcdi_get_board_cfg()
      sfc: Support variable-length response to MCDI GET_BOARD_CFG
      sfc: Expose FPGA bitfile partition through MTD
      sfc: Bump version to 3.2
      sfc: Avoid generating over-length MC_CMD_FLUSH_RX_QUEUES request

Stuart Hodgson (4):
      sfc: Add explicit RX queue flag to channel
      sfc: Add channel specific receive_skb handler and post_remove callback
      sfc: Allow efx_mcdi_rpc to be called in two parts
      sfc: Add support for IEEE-1588 PTP

 drivers/net/ethernet/sfc/Kconfig       |    7 +
 drivers/net/ethernet/sfc/Makefile      |    1 +
 drivers/net/ethernet/sfc/efx.c         |   17 +-
 drivers/net/ethernet/sfc/efx.h         |    1 +
 drivers/net/ethernet/sfc/ethtool.c     |    1 +
 drivers/net/ethernet/sfc/mcdi.c        |   49 +-
 drivers/net/ethernet/sfc/mcdi.h        |    6 +
 drivers/net/ethernet/sfc/mcdi_pcol.h   |   29 +-
 drivers/net/ethernet/sfc/mtd.c         |    7 +-
 drivers/net/ethernet/sfc/net_driver.h  |   29 +-
 drivers/net/ethernet/sfc/nic.h         |   36 +
 drivers/net/ethernet/sfc/ptp.c         | 1483 ++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/rx.c          |   20 +-
 drivers/net/ethernet/sfc/siena.c       |    1 +
 drivers/net/ethernet/sfc/siena_sriov.c |    7 +
 drivers/net/ethernet/sfc/tx.c          |    6 +
 drivers/ptp/ptp_clock.c                |    5 +
 include/linux/pps_kernel.h             |    9 +
 include/linux/ptp_clock_kernel.h       |   10 +-
 19 files changed, 1688 insertions(+), 36 deletions(-)
 create mode 100644 drivers/net/ethernet/sfc/ptp.c

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
