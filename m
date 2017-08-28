From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net v2 6/6] net:ethernet:aquantia: Show info message if bad firmware version detected.
Date: Mon, 28 Aug 2017 21:52:13 +0300
Message-ID: <a692b1c8e8884c0c957fd2e7a8bee423dd8ffafd.1503945861.git.pavel.belous@aquantia.com>
References: <cover.1503945861.git.pavel.belous@aquantia.com>
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
Received: from mail-sn1nam01on0068.outbound.protection.outlook.com ([104.47.32.68]:28764
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751190AbdH1Sxe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 14:53:34 -0400
In-Reply-To: <cover.1503945861.git.pavel.belous@aquantia.com>
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
index 7a1332e..4f5ec9a 100644
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
