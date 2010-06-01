From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 01/12] sfc: Rename struct efx_mcdi_phy_cfg to
 efx_mcdi_phy_data
Date: Tue, 01 Jun 2010 22:17:06 +0100
Message-ID: <1275427026.2114.26.camel@achroite.uk.solarflarecom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50455 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756735Ab0FAVRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:17:09 -0400
In-Reply-To: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of its members are constant capabilities, not configuration.  The
new name is also consistent with the name of the pointer to it in
struct efx_nic and the names of structures used by other PHY drivers.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi_phy.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/sfc/mcdi_phy.c b/drivers/net/sfc/mcdi_phy.c
index 6032c0e..5c23f22 100644
--- a/drivers/net/sfc/mcdi_phy.c
+++ b/drivers/net/sfc/mcdi_phy.c
@@ -20,7 +20,7 @@
 #include "nic.h"
 #include "selftest.h"
 
-struct efx_mcdi_phy_cfg {
+struct efx_mcdi_phy_data {
 	u32 flags;
 	u32 type;
 	u32 supported_cap;
@@ -35,7 +35,7 @@ struct efx_mcdi_phy_cfg {
 };
 
 static int
-efx_mcdi_get_phy_cfg(struct efx_nic *efx, struct efx_mcdi_phy_cfg *cfg)
+efx_mcdi_get_phy_cfg(struct efx_nic *efx, struct efx_mcdi_phy_data *cfg)
 {
 	u8 outbuf[MC_CMD_GET_PHY_CFG_OUT_LEN];
 	size_t outlen;
@@ -259,7 +259,7 @@ static u32 ethtool_to_mcdi_cap(u32 cap)
 
 static u32 efx_get_mcdi_phy_flags(struct efx_nic *efx)
 {
-	struct efx_mcdi_phy_cfg *phy_cfg = efx->phy_data;
+	struct efx_mcdi_phy_data *phy_cfg = efx->phy_data;
 	enum efx_phy_mode mode, supported;
 	u32 flags;
 
@@ -307,7 +307,7 @@ static u32 mcdi_to_ethtool_media(u32 media)
 
 static int efx_mcdi_phy_probe(struct efx_nic *efx)
 {
-	struct efx_mcdi_phy_cfg *phy_data;
+	struct efx_mcdi_phy_data *phy_data;
 	u8 outbuf[MC_CMD_GET_LINK_OUT_LEN];
 	u32 caps;
 	int rc;
@@ -405,7 +405,7 @@ fail:
 
 int efx_mcdi_phy_reconfigure(struct efx_nic *efx)
 {
-	struct efx_mcdi_phy_cfg *phy_cfg = efx->phy_data;
+	struct efx_mcdi_phy_data *phy_cfg = efx->phy_data;
 	u32 caps = (efx->link_advertising ?
 		    ethtool_to_mcdi_cap(efx->link_advertising) :
 		    phy_cfg->forced_cap);
@@ -446,7 +446,7 @@ void efx_mcdi_phy_decode_link(struct efx_nic *efx,
  */
 void efx_mcdi_phy_check_fcntl(struct efx_nic *efx, u32 lpa)
 {
-	struct efx_mcdi_phy_cfg *phy_cfg = efx->phy_data;
+	struct efx_mcdi_phy_data *phy_cfg = efx->phy_data;
 	u32 rmtadv;
 
 	/* The link partner capabilities are only relevent if the
@@ -505,7 +505,7 @@ static void efx_mcdi_phy_remove(struct efx_nic *efx)
 
 static void efx_mcdi_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
-	struct efx_mcdi_phy_cfg *phy_cfg = efx->phy_data;
+	struct efx_mcdi_phy_data *phy_cfg = efx->phy_data;
 	u8 outbuf[MC_CMD_GET_LINK_OUT_LEN];
 	int rc;
 
@@ -535,7 +535,7 @@ static void efx_mcdi_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *e
 
 static int efx_mcdi_phy_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
-	struct efx_mcdi_phy_cfg *phy_cfg = efx->phy_data;
+	struct efx_mcdi_phy_data *phy_cfg = efx->phy_data;
 	u32 caps;
 	int rc;
 
@@ -674,7 +674,7 @@ out:
 static int efx_mcdi_phy_run_tests(struct efx_nic *efx, int *results,
 				  unsigned flags)
 {
-	struct efx_mcdi_phy_cfg *phy_cfg = efx->phy_data;
+	struct efx_mcdi_phy_data *phy_cfg = efx->phy_data;
 	u32 mode;
 	int rc;
 
@@ -712,7 +712,7 @@ static int efx_mcdi_phy_run_tests(struct efx_nic *efx, int *results,
 
 const char *efx_mcdi_phy_test_name(struct efx_nic *efx, unsigned int index)
 {
-	struct efx_mcdi_phy_cfg *phy_cfg = efx->phy_data;
+	struct efx_mcdi_phy_data *phy_cfg = efx->phy_data;
 
 	if (phy_cfg->flags & (1 << MC_CMD_GET_PHY_CFG_BIST_LBN)) {
 		if (index == 0)
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

