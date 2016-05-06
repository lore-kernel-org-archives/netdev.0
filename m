From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/11] i40e: constify i40e_client_ops structure
Date: Fri,  6 May 2016 00:03:48 -0700
Message-ID: <1462518228-30527-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Julia Lawall <Julia.Lawall@lip6.fr>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:40897 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752531AbcEFHGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 03:06:36 -0400
In-Reply-To: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia.lawall@lip6.fr>

The i40e_client_ops structure is never modified, so declare it as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/infiniband/hw/i40iw/i40iw_main.c      | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_client.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/i40iw/i40iw_main.c b/drivers/infiniband/hw/i40iw/i40iw_main.c
index 90e5af2..e41fae24 100644
--- a/drivers/infiniband/hw/i40iw/i40iw_main.c
+++ b/drivers/infiniband/hw/i40iw/i40iw_main.c
@@ -1863,7 +1863,7 @@ static enum i40iw_status_code i40iw_virtchnl_send(struct i40iw_sc_dev *dev,
 }
 
 /* client interface functions */
-static struct i40e_client_ops i40e_ops = {
+static const struct i40e_client_ops i40e_ops = {
 	.open = i40iw_open,
 	.close = i40iw_close,
 	.l2_param_change = i40iw_l2param_change,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.h b/drivers/net/ethernet/intel/i40e/i40e_client.h
index bf6b453..a4601d9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.h
@@ -217,7 +217,7 @@ struct i40e_client {
 #define I40E_CLIENT_FLAGS_LAUNCH_ON_PROBE	BIT(0)
 #define I40E_TX_FLAGS_NOTIFY_OTHER_EVENTS	BIT(2)
 	enum i40e_client_type type;
-	struct i40e_client_ops *ops;	/* client ops provided by the client */
+	const struct i40e_client_ops *ops; /* client ops provided by the client */
 };
 
 static inline bool i40e_client_is_registered(struct i40e_client *client)
-- 
2.5.5
