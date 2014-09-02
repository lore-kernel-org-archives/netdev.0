From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v4 0/3] enic: Add support for rx_copybreak
Date: Wed,  3 Sep 2014 03:17:18 +0530
Message-ID: <1409694441-3843-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, ben@decadent.org.uk,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:63845 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754183AbaIBVsK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 17:48:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements rx_copybreak.

dma_map_single()/dma_unmap_single() is more expensive than alloc_skb & memcpy
for smaller packets. By doing this we can reuse the dma buff which is already
mapped. This is very useful when iommu is on. The default skb copybreak value
is 256.

When iommu is on, we can go much higher than 256. All the drivers that supports
rx_copybreak provides module parameter to change this value. Since module
parameter is the least preferred way for changing driver values, this series
adds ethtool support for setting rx_copybreak.

v4:
Validate tunable length in ethtool_get_tunable, not in driver implemented
function.

Loose tunable_ops array for each tunable type. Define one function and let the
driver use switch case for each type.

Use double underscore for data type in UAPI headers.
Use const qualifier where possible.

v3:
Add tunable namespace to ethtool. Use new ethtool cmd ETHTOOL_S/GTUNABLE to
set/get rx_copybreak from userspace.

v2:
Add new ethtool_cmd for DMA buffer parameters, instead of adding new members to
existing ethtool_ringparam.

Govindarajulu Varadarajan (3):
  enic: implement rx_copybreak
  ethtool: Add generic options for tunables
  enic: Add tunable_ops support for rx_copybreak

 drivers/net/ethernet/cisco/enic/enic.h         |  1 +
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 39 +++++++++++++
 drivers/net/ethernet/cisco/enic/enic_main.c    | 50 +++++++++++++++-
 include/linux/ethtool.h                        |  4 ++
 include/uapi/linux/ethtool.h                   | 28 +++++++++
 net/core/ethtool.c                             | 81 ++++++++++++++++++++++++++
 6 files changed, 200 insertions(+), 3 deletions(-)

-- 
2.1.0
