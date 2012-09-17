From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH] netxen: check for root bus in
 netxen_mask_aer_correctable
Date: Mon, 17 Sep 2012 12:53:26 -0500
Message-ID: <13A253B3F9BEFE43B93C09CF75F63CAA827E3AE9F9@MNEXMB1.qlogic.org>
References: <1347637803-4837-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: "nikolay@redhat.com" <nikolay@redhat.com>,
	Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe003.messaging.microsoft.com ([216.32.180.186]:52616
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756900Ab2IQRxp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 13:53:45 -0400
In-Reply-To: <1347637803-4837-1-git-send-email-nikolay@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


________________________________________
From: nikolay@redhat.com [nikolay@redhat.com]
Sent: Friday, September 14, 2012 9:20 PM
To: Sony Chacko
Cc: Rajesh Borundia; netdev
Subject: [PATCH] netxen: check for root bus in netxen_mask_aer_correctable

From: Nikolay Aleksandrov <nikolay@redhat.com>

Add a check if pdev->bus->self == NULL (root bus). When attaching
a netxen NIC to a VM it can be on the root bus and the guest would
crash in netxen_mask_aer_correctable() because of a NULL pointer
dereference if CONFIG_PCIEAER is present.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 342b3a7..e2a4858 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1378,6 +1378,10 @@ static void netxen_mask_aer_correctable(struct netxen_adapter *adapter)
        struct pci_dev *root = pdev->bus->self;
        u32 aer_pos;

+       /* root bus? */
+       if (!root)
+               return;
+
        if (adapter->ahw.board_type != NETXEN_BRDTYPE_P3_4_GB_MM &&
                adapter->ahw.board_type != NETXEN_BRDTYPE_P3_10G_TP)
                return;
--
1.7.11.4


Looks okay.
