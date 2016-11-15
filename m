From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 2/2] amd-xgbe: Fix maximum GPIO value check
Date: Tue, 15 Nov 2016 16:11:15 -0600
Message-ID: <20161115221115.12403.53949.stgit@tlendack-t1.amdoffice.net>
References: <20161115221055.12403.90574.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <colin.king@canonical.com>, David Miller <davem@davemloft.net>,
        <dan.carpenter@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0081.outbound.protection.outlook.com ([104.47.37.81]:36682
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935038AbcKOWLZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 17:11:25 -0500
In-Reply-To: <20161115221055.12403.90574.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The GPIO support in the hardware allows for up to 16 GPIO pins, enumerated
from 0 to 15.  The driver uses the wrong value (16) to validate the GPIO
pin range in the routines to set and clear the GPIO output pins.  Update
the code to use the correct value (15).

Reported-by: Colin Ian King <colin.king@canonical.com>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 30056e2..aaf0350 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1099,7 +1099,7 @@ static int xgbe_clr_gpio(struct xgbe_prv_data *pdata, unsigned int gpio)
 {
 	unsigned int reg;
 
-	if (gpio > 16)
+	if (gpio > 15)
 		return -EINVAL;
 
 	reg = XGMAC_IOREAD(pdata, MAC_GPIOSR);
@@ -1114,7 +1114,7 @@ static int xgbe_set_gpio(struct xgbe_prv_data *pdata, unsigned int gpio)
 {
 	unsigned int reg;
 
-	if (gpio > 16)
+	if (gpio > 15)
 		return -EINVAL;
 
 	reg = XGMAC_IOREAD(pdata, MAC_GPIOSR);
