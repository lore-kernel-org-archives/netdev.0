From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] ixgbe: initialize interrupt throttle rate
Date: Wed, 27 Aug 2008 18:04:32 -0700
Message-ID: <20080828010432.7539.735.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, stable@kernel.org,
	andy@greyhouse.net, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:26370 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845AbYH1BEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 21:04:37 -0400
Received: by yx-out-2324.google.com with SMTP id 8so80520yxm.1
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 18:04:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>

This commit dropped the setting of the default interrupt throttle rate.

commit 021230d40ae0e6508d6c717b6e0d6d81cd77ac25
Author: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Date:   Mon Mar 3 15:03:45 2008 -0800

    ixgbe: Introduce MSI-X queue vector code

The following patch adds it back.  Without this the default value of 0
causes the performance of this card to be awful.  Restoring these to the
default values yields much better performance.

This regression has been around since 2.6.25.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: stable@kernel.org [2.6.25 and later]
---

 drivers/net/ixgbe/ixgbe_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 53f41b6..a417be7 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2304,6 +2304,12 @@ static int __devinit ixgbe_set_interrupt_capability(struct ixgbe_adapter
 	int vector, v_budget;
 
 	/*
+	 * Set the default interrupt throttle rate.
+	 */
+	adapter->rx_eitr = (1000000 / IXGBE_DEFAULT_ITR_RX_USECS);
+	adapter->tx_eitr = (1000000 / IXGBE_DEFAULT_ITR_TX_USECS);
+
+	/*
 	 * It's easy to be greedy for MSI-X vectors, but it really
 	 * doesn't do us much good if we have a lot more vectors
 	 * than CPU's.  So let's be conservative and only ask for

