From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next v2 03/10] fsl/fman: remove wrong free
Date: Thu, 9 Mar 2017 16:36:58 +0200
Message-ID: <1489070225-7891-4-git-send-email-madalin.bucur@nxp.com>
References: <1489070225-7891-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <camelia.groza@nxp.com>,
        <dan.carpenter@oracle.com>, <linux-kernel@vger.kernel.org>,
        <linuxppc-dev@lists.ozlabs.org>,
        Madalin Bucur <madalin.bucur@nxp.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0064.outbound.protection.outlook.com ([104.47.32.64]:50550
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754704AbdCIOja (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 09:39:30 -0500
In-Reply-To: <1489070225-7891-1-git-send-email-madalin.bucur@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/fman_port.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman_port.c b/drivers/net/ethernet/freescale/fman/fman_port.c
index f314348..57bf44f 100644
--- a/drivers/net/ethernet/freescale/fman/fman_port.c
+++ b/drivers/net/ethernet/freescale/fman/fman_port.c
@@ -1312,7 +1312,7 @@ int fman_port_config(struct fman_port *port, struct fman_port_params *params)
 	/* Allocate the FM driver's parameters structure */
 	port->cfg = kzalloc(sizeof(*port->cfg), GFP_KERNEL);
 	if (!port->cfg)
-		goto err_params;
+		return -EINVAL;
 
 	/* Initialize FM port parameters which will be kept by the driver */
 	port->port_type = port->dts_params.type;
@@ -1393,8 +1393,6 @@ int fman_port_config(struct fman_port *port, struct fman_port_params *params)
 
 err_port_cfg:
 	kfree(port->cfg);
-err_params:
-	kfree(port);
 	return -EINVAL;
 }
 EXPORT_SYMBOL(fman_port_config);
-- 
2.1.0
