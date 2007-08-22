From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/3] e1000e: Remove conditional packet split disable flag
Date: Wed, 22 Aug 2007 08:08:49 -0700
Message-ID: <20070822150849.19918.77272.stgit@localhost.localdomain>
References: <20070822150839.19918.86665.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com,
	akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26576 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762072AbXHVPIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:08:50 -0400
In-Reply-To: <20070822150839.19918.86665.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This flag conflicts with e1000's Kconfig symbol and we'll leave
the feature enabled by default for now.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/netdev.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 420e111..372da46 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2009,7 +2009,6 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 		break;
 	}
 
-#ifndef CONFIG_E1000_DISABLE_PACKET_SPLIT
 	/*
 	 * 82571 and greater support packet-split where the protocol
 	 * header is placed in skb->data and the packet data is
@@ -2029,7 +2028,7 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	pages = PAGE_USE_COUNT(adapter->netdev->mtu);
 	if ((pages <= 3) && (PAGE_SIZE <= 16384) && (rctl & E1000_RCTL_LPE))
 		adapter->rx_ps_pages = pages;
-#endif
+
 	if (adapter->rx_ps_pages) {
 		/* Configure extra packet-split registers */
 		rfctl = er32(RFCTL);
