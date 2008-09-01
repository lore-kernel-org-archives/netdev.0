From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 00/52] sfc: Changes for 2.6.28
Date: Mon, 1 Sep 2008 12:16:22 +0100
Message-ID: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:39680 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751101AbYIALQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:16:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

Here's a first patch series for sfc in 2.6.28 covering minor fixes and
improvements and the addition of EEPROM access and more self-tests
through ethtool.  We have some more changes in the pipeline for new
hardware support which I will submit later.

Ben.

Ben Hutchings (41):
  sfc: Replace net_dev->priv with netdev_priv(net_dev)
  sfc: Change first parameter type of {set,clear}_bit_le() to unsigned
  sfc: Use separate hardware TX queues to select checksum generation
  sfc: Avoid mangling error codes in efx_test_loopback()
  sfc: Reduce delays in SFE4001 initialisation
  sfc: Remove mistaken hardware workaround
  sfc: XMAC statistics fix-ups
  sfc: Remove inclusion of workarounds.h from efx.c
  sfc: Reduce log level for XGXS lane status
  sfc: Self-test reporting cleanup
  sfc: Speed up loopback self-test
  sfc: Don't leak PCI DMA maps in the TSO code when the queue fills up
  sfc: Use pci_map_single() to map the skb header when doing TSO
  sfc: Reduce the size of struct efx_tx_buffer
  sfc: Use explicit bool for boolean variables, parameters and return
    values
  sfc: Set net_device::vlan_features appropriately
  sfc: Cleaned up struct tso_state fields
  sfc: Removed forced inlining of long functions
  sfc: Export boot configuration in EEPROM through ethtool
  sfc: Move CPU counting for RSS into a separate function,
    efx_wanted_rx_queues()
  sfc: Remove efx_channel::has_interrupt
  sfc: Cleanup RX queue information
  sfc: Remove initialisation of RX_FILTER_CTL_REG.NUM_KER
  sfc: Make efx_for_each_channel_rx_queue() more efficient
  sfc: Remove efx_channel::evqnum field
  sfc: Cleanup RX event processing
  sfc: Implement get_sset_count, replacing get_stats_count and
    self_test_count
  sfc: Make PHY flash mode a device attribute, not a module parameter
  sfc: Enable TSO for 802.1q VLAN devices
  sfc: Remove efx_nic_dummy_op_int() as redundant with
    efx_port_dummy_op_int()
  sfc: Remove remnants of multi-port abstraction for MAC registers
  sfc: Remove some unreachable error paths
  sfc: Cleanup reset code
  sfc: Extend self-tests
  sfc: Remove the STATE_RESETTING flag
  sfc: Add check for memory allocation failure in falcon_probe_nic()
  sfc: Remove workaround for old firmware bug
  sfc: Make queue flushes more reliable
  sfc: Disable interrupts after a fatal interrupt occurs until reset
  sfc: Remove obsolete comment about PCI modes
  sfc: Use CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS where appropriate

Neil Turton (1):
  sfc: Insert read memory barrier after checking MAC statistics flag

Steve Hodgson (10):
  sfc: Remove unused field efx_channel::reset_work
  sfc: Reverse the XOFF/XON pause frame control fifo thresholds
  sfc: Do not call netif_{stop,wake}_queue() before register_netdev
  sfc: Rework the bitfield header so that we can identify fields by bit
    number
  sfc: Rework efx_set_multicast_hash()
  sfc: Fix memory BAR release call on error path
  sfc: Serialise tenxpress_special_reset() with statistics fetches
  sfc: Don't use EFX_OWORD_FIELD on an event (64-bit, quad-word)
  sfc: Don't include net_driver.h from falcon_io.h
  sfc: Stop generating bogus events in tenxpress_check_hw()

 drivers/net/sfc/bitfield.h      |  178 +++++---
 drivers/net/sfc/boards.c        |   12 +-
 drivers/net/sfc/boards.h        |    2 -
 drivers/net/sfc/efx.c           |  489 ++++++++-----------
 drivers/net/sfc/efx.h           |   14 +-
 drivers/net/sfc/enum.h          |    9 +-
 drivers/net/sfc/ethtool.c       |  184 ++++----
 drivers/net/sfc/falcon.c        | 1017 ++++++++++++++++++++++++++-------------
 drivers/net/sfc/falcon.h        |   17 +-
 drivers/net/sfc/falcon_hwdefs.h |   80 ++-
 drivers/net/sfc/falcon_io.h     |    1 -
 drivers/net/sfc/falcon_xmac.c   |  346 +++++---------
 drivers/net/sfc/mac.h           |    4 -
 drivers/net/sfc/mdio_10g.c      |   16 +-
 drivers/net/sfc/mdio_10g.h      |   13 +-
 drivers/net/sfc/net_driver.h    |  144 +++---
 drivers/net/sfc/phy.h           |   10 +-
 drivers/net/sfc/rx.c            |   78 ++--
 drivers/net/sfc/rx.h            |    4 +-
 drivers/net/sfc/selftest.c      |  391 ++++++++-------
 drivers/net/sfc/selftest.h      |   13 +-
 drivers/net/sfc/sfe4001.c       |  248 ++++++----
 drivers/net/sfc/spi.h           |   89 ++--
 drivers/net/sfc/tenxpress.c     |  149 ++-----
 drivers/net/sfc/tx.c            |  385 ++++++++-------
 drivers/net/sfc/tx.h            |    2 +-
 drivers/net/sfc/workarounds.h   |    4 -
 drivers/net/sfc/xfp_phy.c       |   12 +-
 28 files changed, 2086 insertions(+), 1825 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
