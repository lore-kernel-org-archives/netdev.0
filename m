From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 13/19] uwb: convert to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:52 -0700
Message-ID: <20090901055129.729527950@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	David Vrabel <david.vrabel@csr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57491 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752805AbZIAF7P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:59:15 -0400
Content-Disposition: inline; filename=uwb.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/uwb/i1480/i1480u-wlp/i1480u-wlp.h	2009-08-29 23:56:10.080512324 -0700
+++ b/drivers/uwb/i1480/i1480u-wlp/i1480u-wlp.h	2009-08-29 23:56:28.821492880 -0700
@@ -267,7 +267,8 @@ extern void i1480u_sysfs_release(struct 
 /* netdev interface */
 extern int i1480u_open(struct net_device *);
 extern int i1480u_stop(struct net_device *);
-extern int i1480u_hard_start_xmit(struct sk_buff *, struct net_device *);
+extern netdev_tx_t i1480u_hard_start_xmit(struct sk_buff *,
+						struct net_device *);
 extern void i1480u_tx_timeout(struct net_device *);
 extern int i1480u_set_config(struct net_device *, struct ifmap *);
 extern int i1480u_change_mtu(struct net_device *, int);
--- a/drivers/uwb/i1480/i1480u-wlp/tx.c	2009-08-29 23:54:51.001529161 -0700
+++ b/drivers/uwb/i1480/i1480u-wlp/tx.c	2009-08-29 23:55:57.929492420 -0700
@@ -503,7 +503,8 @@ out:
  *
  * @net_dev->xmit_lock is held
  */
-int i1480u_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
+netdev_tx_t i1480u_hard_start_xmit(struct sk_buff *skb,
+					 struct net_device *net_dev)
 {
 	int result;
 	struct i1480u *i1480u = netdev_priv(net_dev);

-- 

