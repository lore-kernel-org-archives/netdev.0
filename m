From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/3] mlxsw: spectrum: Reduce number of supported 802.1D bridges
Date: Tue,  5 Apr 2016 10:20:02 +0200
Message-ID: <1459844404-4698-2-git-send-email-jiri@resnulli.us>
References: <1459844404-4698-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	corbet@lwn.net, sfeldma@gmail.com, nicolas.dichtel@6wind.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34361 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756592AbcDEIUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 04:20:10 -0400
Received: by mail-wm0-f42.google.com with SMTP id l6so12426808wml.1
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 01:20:09 -0700 (PDT)
In-Reply-To: <1459844404-4698-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Resources allocated for these bridges at init time cannot be later used
for other purposes. While current number is supported by the device,
it's mostly theoretical with regards to any real use case, which leads
to poor utilization of device's resources. Solve that by reducing the
number.

The long term plan is to make this value (along with others) user
configurable via devlink and write it to NVRAM, so that it can be used
during the next init. Until then we must hardcode such values.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 4b8abaf..d58ab0c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -50,7 +50,7 @@
 
 #define MLXSW_SP_VFID_BASE VLAN_N_VID
 #define MLXSW_SP_VFID_PORT_MAX 512	/* Non-bridged VLAN interfaces */
-#define MLXSW_SP_VFID_BR_MAX 8192	/* Bridged VLAN interfaces */
+#define MLXSW_SP_VFID_BR_MAX 6144	/* Bridged VLAN interfaces */
 #define MLXSW_SP_VFID_MAX (MLXSW_SP_VFID_PORT_MAX + MLXSW_SP_VFID_BR_MAX)
 
 #define MLXSW_SP_LAG_MAX 64
-- 
2.5.5
