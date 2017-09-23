From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 3/3] liquidio: update module parameter fw_type to
 reflect firmware type loaded
Date: Fri, 22 Sep 2017 17:12:51 -0700
Message-ID: <20170923001251.GA1507@felix-thinkpad.cavium.com>
References: <20170923001206.GA1458@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0086.outbound.protection.outlook.com ([104.47.38.86]:46912
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752179AbdIWAM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 20:12:56 -0400
Content-Disposition: inline
In-Reply-To: <20170923001206.GA1458@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index a3c9867..963803b 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1934,10 +1934,12 @@ static int load_firmware(struct octeon_device *oct)
 	char fw_name[LIO_MAX_FW_FILENAME_LEN];
 	char *tmp_fw_type;
 
-	if (fw_type_is_auto())
+	if (fw_type_is_auto()) {
 		tmp_fw_type = LIO_FW_NAME_TYPE_NIC;
-	else
+		strncpy(fw_type, tmp_fw_type, sizeof(fw_type));
+	} else {
 		tmp_fw_type = fw_type;
+	}
 
 	sprintf(fw_name, "%s%s%s_%s%s", LIO_FW_DIR, LIO_FW_BASE_NAME,
 		octeon_get_conf(oct)->card_name, tmp_fw_type,
-- 
1.8.3.1
