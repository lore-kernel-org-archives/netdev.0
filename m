From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/5] net: qlcnic: don't set unused function argument
Date: Thu, 16 Jun 2016 13:38:22 +0200
Message-ID: <20160616113831.4108439-2-arnd@arndb.de>
References: <20160616113831.4108439-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dept-GELinuxNICDev@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616113831.4108439-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get a warning for qlcnic_83xx_get_mac_address when building with
"make W=1":

drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c: In function 'qlcnic_83xx_get_mac_address':
drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c:2156:8: error: parameter 'function' set but not used [-Werror=unused-but-set-parameter]

Clearly this is harmless, but there is also no point for setting
the variable, so we can simply remove the assignment.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index f9640d5ce6ba..bdbcd2b088a0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -2159,7 +2159,6 @@ int qlcnic_83xx_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac,
 	struct qlcnic_cmd_args cmd;
 	u32 mac_low, mac_high;
 
-	function = 0;
 	err = qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_MAC_ADDRESS);
 	if (err)
 		return err;
-- 
2.9.0
