From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v3 0/3] enic: Add support for rx_copybreak
Date: Thu, 14 Aug 2014 14:59:17 +0530
Message-ID: <1408008560-1067-1-git-send-email-_govind@gmx.com>
Cc: ben@decadent.org.uk, stephen@networkplumber.org, ssujith@cisco.com,
	benve@cisco.com, Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:61290 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753155AbaHNJ3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 05:29:41 -0400
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
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 30 +++++++++++++++
 drivers/net/ethernet/cisco/enic/enic_main.c    | 50 +++++++++++++++++++++++--
 include/linux/ethtool.h                        |  6 +++
 include/uapi/linux/ethtool.h                   | 17 +++++++++
 net/core/ethtool.c                             | 51 ++++++++++++++++++++++++++
 6 files changed, 152 insertions(+), 3 deletions(-)

-- 
2.0.4
