From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix issues with fw_type module parameter
Date: Mon, 14 Aug 2017 12:17:56 -0700
Message-ID: <20170814191756.GA1371@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0051.outbound.protection.outlook.com ([104.47.41.51]:2680
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750771AbdHNTSC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 15:18:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Derek Chickles <derek.chickles@cavium.com>

The fw_type module parameter isn't showing up in the
/sys/module/liquidio/parameters directory.  Fix it by setting the read
permission bits for user, group, other in module_param_string().  Revise
the description of fw_type.  Initialize the fw_type static char array with
the default value to conform to the module parameter description.

Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index cbd6287..b8ba2c2 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -59,9 +59,9 @@ static int debug = -1;
 module_param(debug, int, 0644);
 MODULE_PARM_DESC(debug, "NETIF_MSG debug bits");
 
-static char fw_type[LIO_MAX_FW_TYPE_LEN];
-module_param_string(fw_type, fw_type, sizeof(fw_type), 0000);
-MODULE_PARM_DESC(fw_type, "Type of firmware to be loaded. Default \"nic\"");
+static char fw_type[LIO_MAX_FW_TYPE_LEN] = LIO_FW_NAME_TYPE_NIC;
+module_param_string(fw_type, fw_type, sizeof(fw_type), 0444);
+MODULE_PARM_DESC(fw_type, "Type of firmware to be loaded. Default \"nic\".  Use \"none\" to load firmware from flash.");
 
 static u32 console_bitmask;
 module_param(console_bitmask, int, 0644);
