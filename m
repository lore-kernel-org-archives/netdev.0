From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 14/19] rocker: Remove support for bridge FDB learning sync
Date: Thu,  8 Jun 2017 08:44:23 +0200
Message-ID: <20170608064428.4785-15-jiri@resnulli.us>
References: <20170608064428.4785-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com,
        nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32853 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751647AbdFHGpB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 02:45:01 -0400
Received: by mail-wm0-f66.google.com with SMTP id x3so5672201wme.0
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 23:44:55 -0700 (PDT)
In-Reply-To: <20170608064428.4785-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Currently the rocker driver supports an option for disabling syncing
the hardware learned FDBs with the software bridge. This behavior
breaks the bridge offload model and thus it is removed.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index f659dad..0b5a58f 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -1959,7 +1959,6 @@ static int ofdpa_port_fdb_learn(struct ofdpa_port *ofdpa_port,
 	u32 out_pport = ofdpa_port->pport;
 	u32 tunnel_id = 0;
 	u32 group_id = ROCKER_GROUP_NONE;
-	bool syncing = !!(ofdpa_port->brport_flags & BR_LEARNING_SYNC);
 	bool copy_to_cpu = false;
 	int err;
 
@@ -1974,9 +1973,6 @@ static int ofdpa_port_fdb_learn(struct ofdpa_port *ofdpa_port,
 			return err;
 	}
 
-	if (!syncing)
-		return 0;
-
 	if (!ofdpa_port_is_bridged(ofdpa_port))
 		return 0;
 
@@ -2550,7 +2546,7 @@ static int ofdpa_port_pre_init(struct rocker_port *rocker_port)
 	ofdpa_port->rocker_port = rocker_port;
 	ofdpa_port->dev = rocker_port->dev;
 	ofdpa_port->pport = rocker_port->pport;
-	ofdpa_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
+	ofdpa_port->brport_flags = BR_LEARNING;
 	ofdpa_port->ageing_time = BR_DEFAULT_AGEING_TIME;
 	return 0;
 }
-- 
2.9.3
