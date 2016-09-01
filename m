From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 3/6] mlxsw: spectrum: Fix error path in mlxsw_sp_module_init
Date: Thu,  1 Sep 2016 10:37:42 +0200
Message-ID: <1472719065-3247-4-git-send-email-jiri@resnulli.us>
References: <1472719065-3247-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33477 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753129AbcIAIhy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 04:37:54 -0400
Received: by mail-wm0-f67.google.com with SMTP id w207so7295416wmw.0
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 01:37:54 -0700 (PDT)
In-Reply-To: <1472719065-3247-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add forgotten notifier unregister.

Fixes: 99724c18fc66 ("mlxsw: spectrum: Introduce support for router interfaces")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 7291f2c..ec1f7d8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4553,6 +4553,7 @@ static int __init mlxsw_sp_module_init(void)
 	return 0;
 
 err_core_driver_register:
+	unregister_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
 	unregister_netdevice_notifier(&mlxsw_sp_netdevice_nb);
 	return err;
 }
-- 
2.5.5
