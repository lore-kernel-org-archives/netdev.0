From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2013-12-12
Date: Thu, 12 Dec 2013 22:56:17 +0000
Message-ID: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43640 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445Ab3LLW4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 17:56:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit f54b311142a92ea2e42598e347b84e1655caf8e3:

  tcp: auto corking (2013-12-06 12:51:41 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

for you to fetch changes up to ac36baf817c39fc9b53eff190f5901610c5dc5b7:

  sfc: Remove dependency of PTP on having a dedicated channel (2013-12-12 22:07:02 +0000)

An assortment of changes for Linux 3.14:

1. Merge the sfc fixes that you have already merged into net.git.
   (The branch point for those was such that this does not bring in any
   other changes.)
2. Reduce log level for a generally useless warning message, from
   Robert Stonehouse.
3. Include BISTs in ethtool offline self-test for EF10 and recover from
   BISTs initiated through other functions, from Jon Cooper.
4. Improve a sanity check on RX completions.
5. Avoid incrementing RX dropped count while the interface is down, from
   Jon Cooper.
6. Improve hardware sensor naming and log messages, from Edward Cree.
7. Log all unexpected errors returned by firmware, from Edward Cree.
8. Expose another NVRAM partition to userland.
9. Some refactoring of the PTP code in preparation for EF10 support.
10. Various minor cleanups.

Ben.

----------------------------------------------------------------
Alexandre Rames (1):
      sfc: Stop/re-start PTP when stopping/starting the datapath.

Andrew Rybchenko (1):
      sfc: RX buffer allocation takes prefix size into account in IP header alignment

Ben Hutchings (13):
      sfc: Add length checks to efx_xmit_with_hwtstamp() and efx_ptp_is_ptp_tx()
      sfc: Rate-limit log message for PTP packets without a matching timestamp event
      sfc: Maintain current frequency adjustment when applying a time offset
      Merge branch 'sfc-3.13' into master
      sfc: Update MCDI protocol definitions
      sfc: Tighten the check for RX merged completion events
      sfc: Add new sensor names
      sfc: Map MCDI error MC_CMD_ERR_ENOTSUP to Linux EOPNOTSUPP
      sfc: Fold efx_flush_all() into efx_stop_port() and update comments
      sfc: Expose NVRAM_PARTITION_TYPE_LICENSE on EF10
      sfc: Return EBUSY for filter insertion on EF10, matching Falcon/Siena
      sfc: Split PTP multicast filter insertion/removal out of efx_ptp_{start,stop}()
      sfc: Remove dependency of PTP on having a dedicated channel

Edward Cree (3):
      sfc: Report units in sensor warnings
      sfc: Revise sensor names to be more understandable and consistent
      sfc: Log all unexpected MCDI errors

Jon Cooper (3):
      sfc: Add MC BISTs to ethtool offline self test on EF10
      sfc: Make initial fill of RX descriptors synchronous
      sfc: Correct RX dropped count for drops while interface is down

Laurence Evans (1):
      sfc: PTP: Moderate log message on event queue overflow

Robert Stonehouse (3):
      sfc: Refactor efx_mcdi_poll() by introducing efx_mcdi_poll_once()
      sfc: Poll for MCDI completion once before timeout occurs
      sfc: Demote "MC Scheduler error" messages

 drivers/net/ethernet/sfc/ef10.c       | 143 +++++--
 drivers/net/ethernet/sfc/efx.c        |  84 +++-
 drivers/net/ethernet/sfc/efx.h        |   2 +-
 drivers/net/ethernet/sfc/enum.h       |   1 +
 drivers/net/ethernet/sfc/ethtool.c    |   2 +
 drivers/net/ethernet/sfc/falcon.c     |  10 +
 drivers/net/ethernet/sfc/farch.c      |   2 +-
 drivers/net/ethernet/sfc/mcdi.c       | 424 ++++++++++++--------
 drivers/net/ethernet/sfc/mcdi.h       |  19 +
 drivers/net/ethernet/sfc/mcdi_mon.c   |  76 ++--
 drivers/net/ethernet/sfc/mcdi_pcol.h  | 733 ++++++++++++++++++++++++++++++----
 drivers/net/ethernet/sfc/mcdi_port.c  |  89 ++---
 drivers/net/ethernet/sfc/net_driver.h |   9 +
 drivers/net/ethernet/sfc/nic.c        |  12 +
 drivers/net/ethernet/sfc/nic.h        |   7 +-
 drivers/net/ethernet/sfc/ptp.c        | 203 +++++++---
 drivers/net/ethernet/sfc/rx.c         |  15 +-
 drivers/net/ethernet/sfc/selftest.c   |   2 +-
 drivers/net/ethernet/sfc/selftest.h   |   1 +
 drivers/net/ethernet/sfc/siena.c      |   5 +-
 20 files changed, 1418 insertions(+), 421 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
