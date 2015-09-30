From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 2/8] amd-xgbe: Use proper DT / ACPI precedence
 checking
Date: Wed, 30 Sep 2015 08:52:45 -0500
Message-ID: <20150930135245.12605.37559.stgit@tlendack-t1.amdoffice.net>
References: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0086.outbound.protection.outlook.com ([207.46.100.86]:41127
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754057AbbI3OIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 10:08:07 -0400
In-Reply-To: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device tree presence takes precedence over ACPI in the device_* APIs.
The amd-xgbe driver should follow the same precedence. Update the check
on whether to use DT / ACPI to follow this.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index e83bd76..7dd8933 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -371,7 +371,7 @@ static int xgbe_probe(struct platform_device *pdev)
 	set_bit(XGBE_DOWN, &pdata->dev_state);
 
 	/* Check if we should use ACPI or DT */
-	pdata->use_acpi = (!pdata->adev || acpi_disabled) ? 0 : 1;
+	pdata->use_acpi = dev->of_node ? 0 : 1;
 
 	phy_pdev = xgbe_get_phy_pdev(pdata);
 	if (!phy_pdev) {
