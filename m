From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next 2012-08-24
Date: Fri, 24 Aug 2012 20:46:14 +0100
Message-ID: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56615 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757692Ab2HXTqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:46:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 8f4cccbbd92f2ad0ddbbc498ef7cee2a1c3defe9:

  net: Set device operstate at registration time (2012-08-24 12:46:13 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit 8f8b3d518999fd1c342310910aa1e49112c86d05)

1. Change the TX path to stop queues earlier and avoid returning
NETDEV_TX_BUSY.
2. Remove some inefficiencies in soft-TSO.
3. Fix various bugs involving device state transitions and/or reset
scheduling by error handlers.
4. Take advantage of my previous change to operstate initialisation.
5. Miscellaneous cleanup.

Ben.

Ben Hutchings (16):
      sfc: Refactor struct efx_tx_buffer to use a flags field
      sfc: Stop TX queues before they fill up
      sfc: Simplify TSO header buffer allocation
      sfc: Replace tso_state::full_packet_space with ip_base_len
      sfc: Stash header offsets for TSO in struct tso_state
      sfc: Change state names to be clearer, and comment them
      sfc: Hold the RTNL lock for more of the suspend/resume cycle
      sfc: Keep disabled NICs quiescent during suspend/resume
      sfc: Hold RTNL lock (only) when calling efx_stop_interrupts()
      sfc: Never try to stop and start a NIC that is disabled
      sfc: Improve log messages in case we abort probe due to a pending reset
      sfc: Fix reset vs probe/remove/PM races involving efx_nic::state
      sfc: Remove overly paranoid locking assertions from netdev operations
      sfc: Remove bogus comment about MTU change and RX buffer overrun
      sfc: Assign efx and efx->type as early as possible in efx_pci_probe()
      sfc: Fix the initial device operstate

 drivers/net/ethernet/sfc/efx.c           |  235 +++++++-----
 drivers/net/ethernet/sfc/ethtool.c       |    4 +-
 drivers/net/ethernet/sfc/falcon_boards.c |    2 +-
 drivers/net/ethernet/sfc/net_driver.h    |   49 ++--
 drivers/net/ethernet/sfc/nic.c           |    6 +-
 drivers/net/ethernet/sfc/tx.c            |  621 ++++++++++++------------------
 6 files changed, 410 insertions(+), 507 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
