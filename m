From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH] i40e: fix sparse warning
Date: Thu,  5 Feb 2015 15:13:15 +0000
Message-ID: <1423149195-32142-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

this patch fixes following sparse warning:

i40e_lan_hmc.c:911:24: warning: constant 0xFFFFFFFFFFFFFFFF is so big it is unsigned long

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 Found this issue on linux-next (gcc  version 4.8.2,
 sparse version  0.4.5-rc1)and applies on top linux-next.

 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
index 4627588..f221ace 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
@@ -908,7 +908,7 @@ static void i40e_write_qword(u8 *hmc_bits,
 	if (ce_info->width < 64)
 		mask = ((u64)1 << ce_info->width) - 1;
 	else
-		mask = 0xFFFFFFFFFFFFFFFF;
+		mask = 0xFFFFFFFFFFFFFFFFULL;
 
 	/* don't swizzle the bits until after the mask because the mask bits
 	 * will be in a different bit position on big endian machines
-- 
1.9.1
