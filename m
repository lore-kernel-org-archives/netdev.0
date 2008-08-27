From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 2.6.27] ixgbe: initialize interrupt throttle rate
Date: Wed, 27 Aug 2008 17:50:15 -0400
Message-ID: <20080827215014.GA14386@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39247 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752626AbYH0Vw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 17:52:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


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
CC: stable@kernel.org [2.6.25 and later]

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 34bca16..85e07b5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2302,6 +2302,12 @@ static int __devinit ixgbe_set_interrupt_capability(struct ixgbe_adapter
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
