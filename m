From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 12/12] mlxsw: spectrum: router: Don't ignore IPMR notifications
Date: Wed, 27 Sep 2017 08:23:22 +0200
Message-ID: <20170927062322.5476-13-jiri@resnulli.us>
References: <20170927062322.5476-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        linyunsheng@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35867 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751833AbdI0GXg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 02:23:36 -0400
Received: by mail-wm0-f68.google.com with SMTP id r136so10514435wmf.3
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 23:23:35 -0700 (PDT)
In-Reply-To: <20170927062322.5476-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Make the Spectrum router logic not ignore the RTNL_FAMILY_IPMR FIB
notifications.

Past commits added the IPMR VIF and MFC add/del notifications via the
fib_notifier chain. In addition, a code for handling these notifications in
the Spectrum router logic was added. Make the Spectrum router logic not
ignore these notifications and forward the requests to the Spectrum
multicast router offloading logic.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index dbd9c19..ef4b86b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -5159,7 +5159,8 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	struct mlxsw_sp_router *router;
 
 	if (!net_eq(info->net, &init_net) ||
-	    (info->family != AF_INET && info->family != AF_INET6))
+	    (info->family != AF_INET && info->family != AF_INET6 &&
+	     info->family != RTNL_FAMILY_IPMR))
 		return NOTIFY_DONE;
 
 	fib_work = kzalloc(sizeof(*fib_work), GFP_ATOMIC);
-- 
2.9.5
