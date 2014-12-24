From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 0/3] enic: Check for DMA mapping error
Date: Wed, 24 Dec 2014 15:59:35 +0530
Message-ID: <1419416978-1008-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org, sassmann@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:55633 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779AbaLXKcM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Dec 2014 05:32:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After dma mapping the buffers, enic does not call dma_mapping_error() to check
if mapping is successful.

This series fixes the issue by checking return value of pci_dma_mapping_error()
after pci_map_single().

This is reported by redhat here
https://bugzilla.redhat.com/show_bug.cgi?id=1145016

Govindarajulu Varadarajan (3):
  enic: make vnic_wq_buf doubly linked
  enic: check dma_mapping_error
  enic: add stats for dma mapping error

 drivers/net/ethernet/cisco/enic/enic.h         |  14 +++
 drivers/net/ethernet/cisco/enic/enic_ethtool.c |  19 +++-
 drivers/net/ethernet/cisco/enic/enic_main.c    | 152 +++++++++++++++----------
 drivers/net/ethernet/cisco/enic/vnic_stats.h   |   5 +
 drivers/net/ethernet/cisco/enic/vnic_wq.c      |   3 +
 drivers/net/ethernet/cisco/enic/vnic_wq.h      |   1 +
 6 files changed, 135 insertions(+), 59 deletions(-)

-- 
2.2.1
