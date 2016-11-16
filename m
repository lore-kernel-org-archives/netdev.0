From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/8] mlxsw: spectrum_router: Request a dump of FIB tables during init
Date: Wed, 16 Nov 2016 15:09:02 +0100
Message-ID: <1479305343-13167-8-git-send-email-jiri@resnulli.us>
References: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36472 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753571AbcKPOJO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:09:14 -0500
Received: by mail-wm0-f66.google.com with SMTP id m203so11467808wma.3
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:09:14 -0800 (PST)
In-Reply-To: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Make sure the device has a complete view of the FIB tables by invoking
their dump during module init.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index a8011a5..46126d9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2048,6 +2048,7 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 
 	mlxsw_sp->fib_nb.notifier_call = mlxsw_sp_router_fib_event;
 	register_fib_notifier(&mlxsw_sp->fib_nb);
+	fib_notifier_dump(&mlxsw_sp->fib_nb);
 	return 0;
 
 err_neigh_init:
-- 
2.7.4
