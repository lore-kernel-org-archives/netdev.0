From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 0/3] Enable PPS and PTP clocks automatically
Date: Thu, 1 Nov 2012 01:29:57 +0000
Message-ID: <1351733397.2706.62.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>,
	Rodolfo Giometti <giometti@enneenne.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63964 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757002Ab2KABaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 21:30:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are a number of problems with PPS and PTP kconfig options:

1. PPS and PTP_1588_CLOCK depend on EXPERIMENTAL, therefore so must the
   clock drivers.  (And EXPERIMENTAL is deprecated.)
2. PTP_1588_CLOCK depends on PPS, so users or clock driver options must
   explicitly select both.
3. In general, users have to enable too many options to get hardware
   timestamps and PTP working.
4. Boolean options for clock drivers combined with net drivers can force
   the PTP and PPS subsystems to be built-in unnecessarily.

This series changes the options as follows:

1. Nothing depends on EXPERIMENTAL.
2. Only PTP_1588_CLOCK selects PPS.
3, 4. The boolean options are removed and the net driver options select
   PTP_1588_CLOCK.  Where a net driver and associated clock driver are
   separate modules, the clock driver remains optional but is default y.

Ben.

Ben Hutchings (3):
  pps, ptp: Remove dependencies on EXPERIMENTAL
  ptp: Make PTP_1588_CLOCK select rather than depend on PPS
  ptp: Enable clock drivers along with associated net/PHY drivers

 drivers/net/ethernet/intel/Kconfig                 |   28 +------------------
 drivers/net/ethernet/intel/igb/Makefile            |    4 +--
 drivers/net/ethernet/intel/igb/igb.h               |    6 ----
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |    2 -
 drivers/net/ethernet/intel/igb/igb_main.c          |   28 --------------------
 drivers/net/ethernet/intel/ixgbe/Makefile          |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |    6 ----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |    2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   28 --------------------
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig      |   16 -----------
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |    2 -
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   14 ----------
 drivers/net/ethernet/sfc/Kconfig                   |    7 -----
 drivers/net/ethernet/sfc/Makefile                  |    3 +-
 drivers/net/ethernet/sfc/net_driver.h              |    2 -
 drivers/net/ethernet/sfc/nic.h                     |   26 ------------------
 drivers/pps/Kconfig                                |    1 -
 drivers/ptp/Kconfig                                |   19 ++++++-------
 18 files changed, 14 insertions(+), 183 deletions(-)

-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
