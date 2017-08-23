From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net 7/7] net:ethernet:aquantia: Show info message if bad firmware version detected.
Date: Wed, 23 Aug 2017 17:05:08 +0300
Message-ID: <48745acdc819bf5c58e28ce4e64f4ce9d5f6b120.1503496727.git.pavel.belous@aquantia.com>
References: <cover.1503496727.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Igor Russkikh <Igor.Russkikh@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0073.outbound.protection.outlook.com ([104.47.34.73]:48640
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754001AbdHWOH1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 10:07:27 -0400
In-Reply-To: <cover.1503496727.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

We should inform user about wrong firmware version
by printing message in dmesg.

Fixes: 3d2ff7eebe26 ("net: ethernet: aquantia: Atlantic hardware abstraction layer")
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
index eb3ae51..ad4cc53 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
@@ -141,6 +141,12 @@ static int hw_atl_utils_init_ucp(struct aq_hw_s *self,
 
 	err = hw_atl_utils_ver_match(aq_hw_caps->fw_ver_expected,
 				     aq_hw_read_reg(self, 0x18U));
+
+	if (err < 0)
+		pr_err("%s: Bad FW version detected: expected=%x, actual=%x\n",
+		       AQ_CFG_DRV_NAME,
+		       aq_hw_caps->fw_ver_expected,
+		       aq_hw_read_reg(self, 0x18U));
 	return err;
 }
 
-- 
2.7.4
