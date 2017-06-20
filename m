From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: intel: e1000e: add check on e1e_wphy() return value
Date: Tue, 20 Jun 2017 16:22:34 -0500
Message-ID: <20170620212234.GA10957@embeddedgus>
References: <20170518172223.Horde.5kLLwxMJWThQKv0bAxTsk4D@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170518172223.Horde.5kLLwxMJWThQKv0bAxTsk4D@gator4166.hostgator.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check return value from call to e1e_wphy(). This value is being
checked during previous calls to function e1e_wphy() and it seems
a check was missing here.

Addresses-Coverity-ID: 1226905
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 68ea8b4..d6d4ed7 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -2437,6 +2437,8 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 		if (hw->phy.revision < 2) {
 			e1000e_phy_sw_reset(hw);
 			ret_val = e1e_wphy(hw, MII_BMCR, 0x3140);
+			if (ret_val)
+				return ret_val;
 		}
 	}
 
-- 
2.5.0
