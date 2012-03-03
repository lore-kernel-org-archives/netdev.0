From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/4] net: dcb: getnumtcs()/setnumtcs() should return an int
Date: Fri,  2 Mar 2012 18:24:22 -0800
Message-ID: <1330741468-23900-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Eilon Greenstein <eilong@broadcom.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17197 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751028Ab2CCCYf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 21:24:35 -0500
In-Reply-To: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

{g|s}etnumtcs() today returns a u8 that is only used by the DCB code
to verify no error occurred. Today the driver implementations return
negative error codes which end up being non-zero so the logic works
out but triggers some sparse warnings.

To fix the sparse warnings convert the return value to an int.

CC: Eilon Greenstein <eilong@broadcom.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c |    4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |    4 ++--
 include/net/dcbnl.h                             |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 9a9bd3a..9a4ed05 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -2142,7 +2142,7 @@ static u8 bnx2x_dcbnl_get_cap(struct net_device *netdev, int capid, u8 *cap)
 	return rval;
 }
 
-static u8 bnx2x_dcbnl_get_numtcs(struct net_device *netdev, int tcid, u8 *num)
+static int bnx2x_dcbnl_get_numtcs(struct net_device *netdev, int tcid, u8 *num)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
 	u8 rval = 0;
@@ -2169,7 +2169,7 @@ static u8 bnx2x_dcbnl_get_numtcs(struct net_device *netdev, int tcid, u8 *num)
 	return rval;
 }
 
-static u8 bnx2x_dcbnl_set_numtcs(struct net_device *netdev, int tcid, u8 num)
+static int bnx2x_dcbnl_set_numtcs(struct net_device *netdev, int tcid, u8 num)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
 	DP(NETIF_MSG_LINK, "num tcs = %d; Not supported\n", num);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 95e5d11..dde65f9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -490,7 +490,7 @@ static u8 ixgbe_dcbnl_getcap(struct net_device *netdev, int capid, u8 *cap)
 	return 0;
 }
 
-static u8 ixgbe_dcbnl_getnumtcs(struct net_device *netdev, int tcid, u8 *num)
+static int ixgbe_dcbnl_getnumtcs(struct net_device *netdev, int tcid, u8 *num)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	u8 rval = 0;
@@ -514,7 +514,7 @@ static u8 ixgbe_dcbnl_getnumtcs(struct net_device *netdev, int tcid, u8 *num)
 	return rval;
 }
 
-static u8 ixgbe_dcbnl_setnumtcs(struct net_device *netdev, int tcid, u8 num)
+static int ixgbe_dcbnl_setnumtcs(struct net_device *netdev, int tcid, u8 num)
 {
 	return -EINVAL;
 }
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index 2cd66d0..f55c980 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -72,8 +72,8 @@ struct dcbnl_rtnl_ops {
 	void (*getpfccfg)(struct net_device *, int, u8 *);
 	u8   (*setall)(struct net_device *);
 	u8   (*getcap)(struct net_device *, int, u8 *);
-	u8   (*getnumtcs)(struct net_device *, int, u8 *);
-	u8   (*setnumtcs)(struct net_device *, int, u8);
+	int  (*getnumtcs)(struct net_device *, int, u8 *);
+	int  (*setnumtcs)(struct net_device *, int, u8);
 	u8   (*getpfcstate)(struct net_device *);
 	void (*setpfcstate)(struct net_device *, u8);
 	void (*getbcncfg)(struct net_device *, int, u32 *);
-- 
1.7.7.6
