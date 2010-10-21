From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 04/12] atl1c: make functions static
Date: Thu, 21 Oct 2010 10:50:49 -0700
Message-ID: <20101021175148.318737783@vyatta.com>
References: <20101021175045.625707607@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jie Yang <Jie.Yang@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36298 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756312Ab0JUSBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 14:01:04 -0400
Content-Disposition: inline; filename=atl1c_local.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The up/down are only used in this file.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/atl1c/atl1c.h	2010-10-21 08:50:30.693060799 -0700
+++ b/drivers/net/atl1c/atl1c.h	2010-10-21 08:52:00.449585276 -0700
@@ -631,8 +631,6 @@ struct atl1c_adapter {
 extern char atl1c_driver_name[];
 extern char atl1c_driver_version[];
 
-extern int atl1c_up(struct atl1c_adapter *adapter);
-extern void atl1c_down(struct atl1c_adapter *adapter);
 extern void atl1c_reinit_locked(struct atl1c_adapter *adapter);
 extern s32 atl1c_reset_hw(struct atl1c_hw *hw);
 extern void atl1c_set_ethtool_ops(struct net_device *netdev);
--- a/drivers/net/atl1c/atl1c_main.c	2010-10-21 08:50:30.717063103 -0700
+++ b/drivers/net/atl1c/atl1c_main.c	2010-10-21 08:52:00.453585652 -0700
@@ -66,6 +66,8 @@ static void atl1c_set_aspm(struct atl1c_
 static void atl1c_setup_mac_ctrl(struct atl1c_adapter *adapter);
 static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter, u8 que,
 		   int *work_done, int work_to_do);
+static int atl1c_up(struct atl1c_adapter *adapter);
+static void atl1c_down(struct atl1c_adapter *adapter);
 
 static const u16 atl1c_pay_load_size[] = {
 	128, 256, 512, 1024, 2048, 4096,
@@ -2309,7 +2311,7 @@ static int atl1c_request_irq(struct atl1
 	return err;
 }
 
-int atl1c_up(struct atl1c_adapter *adapter)
+static int atl1c_up(struct atl1c_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	int num;
@@ -2351,7 +2353,7 @@ err_alloc_rx:
 	return err;
 }
 
-void atl1c_down(struct atl1c_adapter *adapter)
+static void atl1c_down(struct atl1c_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 


