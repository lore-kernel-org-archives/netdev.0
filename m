From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2013-09-23
Date: Mon, 23 Sep 2013 19:59:01 +0100
Message-ID: <1379962741.2485.58.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38786 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635Ab3IWS7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 14:59:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit dcb30e659287a6b40dafed1362532da42ec27229:

  Merge tag 'arm64-stable' of git://git.kernel.org/pub/scm/linux/kernel/git/cmarinas/linux-aarch64 (2013-09-20 08:18:51 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

for you to fetch changes up to c47b2d9d56832e7ff1a20bd598623de42701a3a3:

  sfc: Support ARFS for IPv6 flows (2013-09-20 19:32:00 +0100)

1. Some cleanup from Fengguang Wu and his kbuild robot.
2. Support for ethtool register dump on EF10.
3. Change soft-TSO to take advantage of firmware assistance on EF10.
4. Support for PIO TX buffers and descriptors on EF10, enabled on
architectures that support write-combining mappings.
5. Accelerated RFS support for TCP/IPv6 and UDP/IPv6 on EF10.

The same changes as in the last request, minus the tracepoints which
I'll submit separately in a generic form.  This branch has also been
rebased on a more recent net-next (and re-tested).

I won't re-post the patches unless you insist.

Ben.

----------------------------------------------------------------
Ben Hutchings (7):
      sfc: Add EF10 registers to register dump
      sfc: Fold tso_get_head_fragment() into tso_start()
      sfc: Implement firmware-assisted TSO for EF10
      sfc: Allocate and link PIO buffers; map them with write-combining
      sfc: Separate out queue-empty check from efx_nic_may_push_tx_desc()
      sfc: Introduce inline functions to simplify TX insertion
      sfc: Support ARFS for IPv6 flows

Fengguang Wu (2):
      sfc: efx_ethtool_get_ts_info() can be static
      sfc: efx_ef10_filter_update_rx_scatter() can be static

Jon Cooper (1):
      sfc: Use TX PIO for sufficiently small packets

 drivers/net/ethernet/sfc/ef10.c       | 319 +++++++++++++++++++++++++-
 drivers/net/ethernet/sfc/ef10_regs.h  |   1 +
 drivers/net/ethernet/sfc/efx.h        |   1 +
 drivers/net/ethernet/sfc/ethtool.c    |   5 +-
 drivers/net/ethernet/sfc/io.h         |   5 +
 drivers/net/ethernet/sfc/net_driver.h |   7 +
 drivers/net/ethernet/sfc/nic.c        |  73 +++---
 drivers/net/ethernet/sfc/nic.h        |  46 +++-
 drivers/net/ethernet/sfc/rx.c         |  90 +++++---
 drivers/net/ethernet/sfc/tx.c         | 419 +++++++++++++++++++++++++++-------
 10 files changed, 807 insertions(+), 159 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
