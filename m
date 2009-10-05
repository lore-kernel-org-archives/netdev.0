From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] dcb: data center bridging ops should be r/o
Date: Mon, 5 Oct 2009 09:01:03 -0700
Message-ID: <20091005090103.0340ef29@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sf.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56053 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143AbZJEQBp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 12:01:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The data center bridging ops structure can be const

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ixgbe/ixgbe.h	2009-10-03 21:40:25.712809970 -0700
+++ b/drivers/net/ixgbe/ixgbe.h	2009-10-03 21:40:33.490342038 -0700
@@ -397,7 +397,7 @@ enum ixgbe_boards {
 extern struct ixgbe_info ixgbe_82598_info;
 extern struct ixgbe_info ixgbe_82599_info;
 #ifdef CONFIG_IXGBE_DCB
-extern struct dcbnl_rtnl_ops dcbnl_ops;
+extern const struct dcbnl_rtnl_ops dcbnl_ops;
 extern int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
                               struct ixgbe_dcb_config *dst_dcb_cfg,
                               int tc_max);
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c	2009-10-03 21:39:54.710299317 -0700
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c	2009-10-03 21:40:05.990317034 -0700
@@ -563,7 +563,7 @@ static u8 ixgbe_dcbnl_setapp(struct net_
 	return rval;
 }
 
-struct dcbnl_rtnl_ops dcbnl_ops = {
+const struct dcbnl_rtnl_ops dcbnl_ops = {
 	.getstate	= ixgbe_dcbnl_get_state,
 	.setstate	= ixgbe_dcbnl_set_state,
 	.getpermhwaddr	= ixgbe_dcbnl_get_perm_hw_addr,
--- a/include/linux/netdevice.h	2009-10-03 21:40:52.730300256 -0700
+++ b/include/linux/netdevice.h	2009-10-03 21:41:10.362812001 -0700
@@ -909,7 +909,7 @@ struct net_device
 
 #ifdef CONFIG_DCB
 	/* Data Center Bridging netlink ops */
-	struct dcbnl_rtnl_ops *dcbnl_ops;
+	const struct dcbnl_rtnl_ops *dcbnl_ops;
 #endif
 
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
