From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2013-09-21
Date: Sat, 21 Sep 2013 19:31:23 +0100
Message-ID: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32518 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969Ab3IUSb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 14:31:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit e7d33bb5ea82922e6ddcfc6b28a630b1a4ced071:

  lockref: add ability to mark lockrefs "dead" (2013-09-07 15:49:18 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

for you to fetch changes up to 48419e3f080704470ffa1350311c6d5640eb4da6:

  sfc: Add static tracepoints to datapath (2013-09-20 01:18:51 +0100)

1. Some cleanup from Fengguang Wu and his kbuild robot.
2. Support for ethtool register dump on EF10.
3. Change soft-TSO to take advantage of firmware assistance on EF10.
4. Support for PIO TX buffers and descriptors on EF10, enabled on
architectures that support write-combining mappings.
5. Accelerated RFS support for TCP/IPv6 and UDP/IPv6 on EF10.
6. Optional static tracepoints to support testing of various offload
features.

Ben.

----------------------------------------------------------------
Ben Hutchings (8):
      sfc: Add EF10 registers to register dump
      sfc: Fold tso_get_head_fragment() into tso_start()
      sfc: Implement firmware-assisted TSO for EF10
      sfc: Allocate and link PIO buffers; map them with write-combining
      sfc: Separate out queue-empty check from efx_nic_may_push_tx_desc()
      sfc: Introduce inline functions to simplify TX insertion
      sfc: Support ARFS for IPv6 flows
      sfc: Add static tracepoints to datapath

Fengguang Wu (2):
      sfc: efx_ethtool_get_ts_info() can be static
      sfc: efx_ef10_filter_update_rx_scatter() can be static

Jon Cooper (1):
      sfc: Use TX PIO for sufficiently small packets

 MAINTAINERS                           |   1 +
 drivers/net/ethernet/sfc/Kconfig      |  14 ++
 drivers/net/ethernet/sfc/ef10.c       | 319 ++++++++++++++++++++++++-
 drivers/net/ethernet/sfc/ef10_regs.h  |   1 +
 drivers/net/ethernet/sfc/efx.c        |   6 +
 drivers/net/ethernet/sfc/efx.h        |   1 +
 drivers/net/ethernet/sfc/ethtool.c    |   5 +-
 drivers/net/ethernet/sfc/io.h         |   5 +
 drivers/net/ethernet/sfc/net_driver.h |   7 +
 drivers/net/ethernet/sfc/nic.c        |  73 +++---
 drivers/net/ethernet/sfc/nic.h        |  46 +++-
 drivers/net/ethernet/sfc/ptp.c        |   3 +
 drivers/net/ethernet/sfc/rx.c         |  92 +++++---
 drivers/net/ethernet/sfc/tx.c         | 422 +++++++++++++++++++++++++++-------
 include/trace/events/sfc.h            | 160 +++++++++++++
 15 files changed, 996 insertions(+), 159 deletions(-)
 create mode 100644 include/trace/events/sfc.h

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
