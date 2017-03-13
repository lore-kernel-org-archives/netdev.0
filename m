From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/10] mlxsw: spectrum_router: Don't destroy RIF if L3 slave
Date: Mon, 13 Mar 2017 08:38:30 +0100
Message-ID: <1489390713-2634-7-git-send-email-jiri@resnulli.us>
References: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36713 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751738AbdCMHis (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 03:38:48 -0400
Received: by mail-wm0-f68.google.com with SMTP id v190so8330895wme.3
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 00:38:47 -0700 (PDT)
In-Reply-To: <1489390713-2634-1-git-send-email-jiri@resnulli.us>
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
index 0eeb556..64f0dc7 100644
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
@@ -2658,7 +2659,7 @@ static bool mlxsw_sp_rif_should_config(struct mlxsw_sp_rif *r,
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
