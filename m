From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net-next 0/8] RX NFC support for hash-based filters
Date: Tue, 3 Jan 2012 21:56:59 +0000
Message-ID: <1325627819.2832.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:36702 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754125Ab2ACV5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 16:57:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Fix gianfar's validation of filter rule locations.  In the previous
   version of this series, this was a requirement for part 2, but that's
   no longer the case.

2. Extend ethtool RX NFC rules API to support hash-based filter hardware
   in which rule locations should be selected by the driver or firmware.

3. Change the sfc driver to implement this API instead of RX n-tuple.

4. Remove support for RX n-tuple, now that there are no in-tree
   implementations.

Ben.

Ben Hutchings (8):
  gianfar: Reject out-of-range RX NFC locations
  ethtool: Allow drivers to select RX NFC rule locations
  sfc: Change filter ID generation to satisfy priority semantics of RX
    NFC
  sfc: Use consistent types for filter IDs, indices and search depths
  sfc: Add support for retrieving and removing filters by ID
  sfc: Implement ethtool RX NFC rules API instead of n-tuple API
  sfc: Remove now-unused filter function
  ethtool: Remove ethtool_ops::set_rx_ntuple operation

 drivers/net/ethernet/freescale/gianfar_ethtool.c |    5 +-
 drivers/net/ethernet/sfc/efx.h                   |   16 +-
 drivers/net/ethernet/sfc/ethtool.c               |  188 +++++++++++---
 drivers/net/ethernet/sfc/filter.c                |  310 +++++++++++++++++++---
 drivers/net/ethernet/sfc/filter.h                |   12 +
 include/linux/ethtool.h                          |   30 ++-
 net/core/ethtool.c                               |   66 +----
 net/socket.c                                     |    2 +-
 8 files changed, 484 insertions(+), 145 deletions(-)

-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
