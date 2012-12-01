From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2012-12-01
Date: Sat, 1 Dec 2012 04:40:21 +0000
Message-ID: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55577 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420Ab2LAEkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:40:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit bb728820fe7c42fdb838ab2745fb5fe6b18b5ffa:

  core: make GRO methods static. (2012-11-29 13:18:32 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit b9cc977d9d4d1866ee83df38815f4b3b34d99dd9)

1. More workarounds for TX queue flush failures that can occur during
   interface reconfiguration.
2. Fix spurious failure of a firmware request running during a system
   clock change, e.g. ntpd started at the same time as driver load.
3. Fix inconsistent statistics after a firmware upgrade.
4. Fix a variable (non-)initialisation in offline self-test that can
   make it more disruptive than intended.
5. Fix a race that can (at least) cause an assertion failure.
6. Miscellaneous cleanup.

Ben.


Ben Hutchings (11):
      sfc: Fix byte order warnings for ethtool RX filter interface
      sfc: Fix byte order warning in self-test
      sfc: Really disable flow control while flushing
      sfc: Delete redundant page_addr variable from efx_init_rx_buffers_page()
      sfc: Fix check for failure of MC_CMD_FLUSH_RX_QUEUES
      sfc: Remove confusing MMIO functions
      sfc: Correctly initialise reset_method in siena_test_chip()
      sfc: Do not initialise buffer in efx_alloc_special_buffer()
      sfc: Reset driver's MAC stats after MC reboot seen
      sfc: Fix timekeeping in efx_mcdi_poll()
      sfc: Make module parameters really boolean

Daniel Pieczko (2):
      sfc: Work-around flush timeout when flushes have completed
      sfc: lock TX queues when calling netif_device_detach()

 drivers/net/ethernet/sfc/efx.c         |   12 ++--
 drivers/net/ethernet/sfc/efx.h         |   13 +++++
 drivers/net/ethernet/sfc/ethtool.c     |   25 ++++++----
 drivers/net/ethernet/sfc/falcon.c      |    2 +
 drivers/net/ethernet/sfc/io.h          |   43 ++++++-----------
 drivers/net/ethernet/sfc/mcdi.c        |   23 ++++++---
 drivers/net/ethernet/sfc/net_driver.h  |    3 +
 drivers/net/ethernet/sfc/nic.c         |   81 ++++++++++++++++++++++++++------
 drivers/net/ethernet/sfc/nic.h         |    2 +
 drivers/net/ethernet/sfc/rx.c          |    6 +--
 drivers/net/ethernet/sfc/selftest.c    |    4 +-
 drivers/net/ethernet/sfc/siena.c       |   17 ++++++-
 drivers/net/ethernet/sfc/siena_sriov.c |    8 +--
 13 files changed, 156 insertions(+), 83 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
