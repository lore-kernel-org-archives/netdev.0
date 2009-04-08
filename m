From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 11/11] netxen: cache align register map table
Date: Wed,  8 Apr 2009 01:50:48 -0700
Message-ID: <1239180648-29842-12-git-send-email-dhananjay@netxen.com>
References: <1239180648-29842-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:49854 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758786AbZDHIvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2009 04:51:06 -0400
In-Reply-To: <1239180648-29842-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aligning register offset translation table imporves performance
on rx side.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hw.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 9439f89..3bb2b8c 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -89,7 +89,8 @@ static void __iomem *pci_base_offset(struct netxen_adapter *adapter,
 }
 
 #define CRB_WIN_LOCK_TIMEOUT 100000000
-static crb_128M_2M_block_map_t crb_128M_2M_map[64] = {
+static crb_128M_2M_block_map_t
+crb_128M_2M_map[64] __cacheline_aligned_in_smp = {
     {{{0, 0,         0,         0} } },		/* 0: PCI */
     {{{1, 0x0100000, 0x0102000, 0x120000},	/* 1: PCIE */
 	  {1, 0x0110000, 0x0120000, 0x130000},
-- 
1.6.0.2

