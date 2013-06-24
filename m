From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2013-06-24
Date: Mon, 24 Jun 2013 21:11:48 +0100
Message-ID: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17246 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745Ab3FXULw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 16:11:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 37173488400704f1a05656616cd12baa9e03173b:

  bnx2x: Fix compilation with no IOV support (2013-06-24 01:47:47 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

for you to fetch changes up to 636d73da27e83ce4882f8823f79063bb37980961:

  sfc: Improve test for IOMMU in use (2013-06-24 20:02:53 +0100)

1. Make EEH recovery work when using legacy interrupts, from Alexandre
   Rames.

2. Enable accelerated RFS for VLAN-tagged flows, from Andy Lutomirski.

3. Improve performance for non-TCP (and particularly UDP) traffic, which
   regressed in 3.10 when we switched to always allocating paged RX
   buffers.  Partly by Jon Cooper.

4. Some minor bug fixes to IOMMU detection, timestamping capabilities,
   and IRQ cleanup on the probe failure path.

I've dropped the RX skb cache, which improved some benchmarks but
perhaps needs some reworking to be more generally useful.

Ben.

----------------------------------------------------------------
Alexandre Rames (1):
      sfc: Fix EEH with legacy interrupts.

Andy Lutomirski (1):
      sfc: Enable accelerated RFS on vlans

Ben Hutchings (5):
      sfc: Report software timestamping capabilities
      sfc: Define and set RX buffer flag for packets parsed as TCP
      sfc: Do not pass non-TCP packets into GRO code
      sfc: Fix IRQ cleanup in case of a probe failure
      sfc: Improve test for IOMMU in use

Jon Cooper (2):
      sfc: Enable RX checksum offload for packets not handled by GRO
      sfc: Increase size of RX SKB header area

 drivers/net/ethernet/sfc/efx.c        | 40 +++----------------
 drivers/net/ethernet/sfc/efx.h        |  1 +
 drivers/net/ethernet/sfc/ethtool.c    | 16 +++++++-
 drivers/net/ethernet/sfc/filter.c     | 15 ++++++-
 drivers/net/ethernet/sfc/net_driver.h |  2 +
 drivers/net/ethernet/sfc/nic.c        | 74 ++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/sfc/nic.h        |  4 +-
 drivers/net/ethernet/sfc/ptp.c        | 13 +++---
 drivers/net/ethernet/sfc/rx.c         |  8 ++--
 9 files changed, 114 insertions(+), 59 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
