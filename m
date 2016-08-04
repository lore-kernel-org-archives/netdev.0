From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net 3/3] mlxsw: spectrum: Add missing DCB rollback in error path
Date: Thu, 4 Aug 2016 17:36:22 +0300
Message-ID: <1470321382-10426-4-git-send-email-idosch@mellanox.com>
References: <1470321382-10426-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <jiri@mellanox.com>,
	<eladr@mellanox.com>, <yotamg@mellanox.com>, <nogahf@mellanox.com>,
	<ogerlitz@mellanox.com>, "Ido Schimmel" <idosch@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0089.outbound.protection.outlook.com ([104.47.2.89]:20160
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965309AbcHDTRk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 15:17:40 -0400
In-Reply-To: <1470321382-10426-1-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We correctly execute mlxsw_sp_port_dcb_fini() when port is removed, but
I missed its rollback in the error path of port creation, so add it.

Fixes: f00817df2b42 ("mlxsw: spectrum: Introduce support for Data Center Bridging (DCB)")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index c3e6150..e1b8f62 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2220,6 +2220,7 @@ err_port_vlan_init:
 err_core_port_init:
 	unregister_netdev(dev);
 err_register_netdev:
+	mlxsw_sp_port_dcb_fini(mlxsw_sp_port);
 err_port_dcb_init:
 err_port_ets_init:
 err_port_buffers_init:
-- 
2.8.2
