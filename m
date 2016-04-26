From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/8] cxgb4: Properly decode port module type
Date: Tue, 26 Apr 2016 20:10:25 +0530
Message-ID: <1461681629-28275-5-git-send-email-hariprasad@chelsio.com>
References: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:39712 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751845AbcDZOgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 10:36:31 -0400
In-Reply-To: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Decode and log port module error, unknown modules and unsupported
modules.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index b8dc7921b258..abc425bfc744 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -337,6 +337,17 @@ void t4_os_portmod_changed(const struct adapter *adap, int port_id)
 		netdev_info(dev, "port module unplugged\n");
 	else if (pi->mod_type < ARRAY_SIZE(mod_str))
 		netdev_info(dev, "%s module inserted\n", mod_str[pi->mod_type]);
+	else if (pi->mod_type == FW_PORT_MOD_TYPE_NOTSUPPORTED)
+		netdev_info(dev, "%s: unsupported port module inserted\n",
+			    dev->name);
+	else if (pi->mod_type == FW_PORT_MOD_TYPE_UNKNOWN)
+		netdev_info(dev, "%s: unknown port module inserted\n",
+			    dev->name);
+	else if (pi->mod_type == FW_PORT_MOD_TYPE_ERROR)
+		netdev_info(dev, "%s: transceiver module error\n", dev->name);
+	else
+		netdev_info(dev, "%s: unknown module type %d inserted\n",
+			    dev->name, pi->mod_type);
 }
 
 int dbfifo_int_thresh = 10; /* 10 == 640 entry threshold */
-- 
2.3.4
