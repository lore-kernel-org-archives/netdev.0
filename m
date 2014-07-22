From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 0/3] enic: Add support for rx_copybreak
Date: Tue, 22 Jul 2014 23:01:05 +0530
Message-ID: <1406050268-13329-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org, ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:53350 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755939AbaGVRbq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 13:31:46 -0400
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

Govindarajulu Varadarajan (3):
  enic: implement rx_copybreak
  ethtool: add rx_copybreak support
  enic: add ethtool support for set/get rx_copybreak

 drivers/net/ethernet/cisco/enic/enic.h         |  1 +
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 31 ++++++++++++++++
 drivers/net/ethernet/cisco/enic/enic_main.c    | 50 ++++++++++++++++++++++++--
 include/uapi/linux/ethtool.h                   |  2 ++
 4 files changed, 81 insertions(+), 3 deletions(-)

-- 
2.0.2
