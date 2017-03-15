From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 6/9] mlxsw: spectrum_router: Don't destroy RIF if L3 slave
Date: Wed, 15 Mar 2017 12:05:09 +0100
Message-ID: <1489575912-6469-7-git-send-email-jiri@resnulli.us>
References: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34532 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753855AbdCOLFd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 07:05:33 -0400
Received: by mail-wr0-f193.google.com with SMTP id u48so1591252wrc.1
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 04:05:32 -0700 (PDT)
In-Reply-To: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We usually destroy the netdev's router interface (RIF) when the last IP
address is removed from it.

However, we shouldn't do that if it's enslaved to an L3 master device.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index c29713a..ff3cf55 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -41,6 +41,7 @@
 #include <linux/in6.h>
 #include <linux/notifier.h>
 #include <linux/inetdevice.h>
+#include <linux/netdevice.h>
 #include <net/netevent.h>
 #include <net/neighbour.h>
 #include <net/arp.h>
@@ -2669,7 +2670,7 @@ static bool mlxsw_sp_rif_should_config(struct mlxsw_sp_rif *r,
 			return true;
 		return false;
 	case NETDEV_DOWN:
-		if (r && !in_dev->ifa_list)
+		if (r && !in_dev->ifa_list && !netif_is_l3_slave(r->dev))
 			return true;
 		/* It is possible we already removed the RIF ourselves
 		 * if it was assigned to a netdev that is now a bridge
-- 
2.7.4
