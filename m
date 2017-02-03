From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH 1/1] bonding: Remove unnecessary returned value check
Date: Thu,  2 Feb 2017 23:46:21 -0500
Message-ID: <1486097181-31568-1-git-send-email-yanjun.zhu@oracle.com>
To: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38361 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752272AbdBCEqo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 23:46:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function bond_info_query alwarys returns 0. As such, in the function
bond_do_ioctl, it is not necessary to check the returned value. So the
interface type of the function bond_info_query is changed to void. The
redundant check is removed.

Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 drivers/net/bonding/bond_main.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8029dd4..6732225 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1993,11 +1993,10 @@ static int  bond_release_and_destroy(struct net_device *bond_dev,
 	return ret;
 }
 
-static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
+static void bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	bond_fill_ifbond(bond, info);
-	return 0;
 }
 
 static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *info)
@@ -3411,12 +3410,11 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 		if (copy_from_user(&k_binfo, u_binfo, sizeof(ifbond)))
 			return -EFAULT;
 
-		res = bond_info_query(bond_dev, &k_binfo);
-		if (res == 0 &&
-		    copy_to_user(u_binfo, &k_binfo, sizeof(ifbond)))
+		bond_info_query(bond_dev, &k_binfo);
+		if (copy_to_user(u_binfo, &k_binfo, sizeof(ifbond)))
 			return -EFAULT;
 
-		return res;
+		return 0;
 	case BOND_SLAVE_INFO_QUERY_OLD:
 	case SIOCBONDSLAVEINFOQUERY:
 		u_sinfo = (struct ifslave __user *)ifr->ifr_data;
-- 
2.7.4
