From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] rocker: fix rocker_world_port_obj_vlan_add()
Date: Tue, 23 Feb 2016 12:37:52 +0300
Message-ID: <20160223093752.GA4030@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30483 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbcBWJiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 04:38:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were changing return values and accidentally made
rocker_world_port_obj_vlan_add() into a no-op.

Fixes: fccd84d44912 ('rocker: return -EOPNOTSUPP for undefined world ops')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index acafbf8..28b775e 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1598,7 +1598,6 @@ rocker_world_port_obj_vlan_add(struct rocker_port *rocker_port,
 
 	if (!wops->port_obj_vlan_add)
 		return -EOPNOTSUPP;
-		return 0;
 	return wops->port_obj_vlan_add(rocker_port, vlan, trans);
 }
 
