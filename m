From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net v2] qed: Fix uninitialized data in aRFS infrastructure
Date: Sun, 14 May 2017 12:21:23 +0300
Message-ID: <1494753683-3429-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <arnd@arndb.de>, <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0040.outbound.protection.outlook.com ([104.47.41.40]:7525
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751369AbdENJVb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 14 May 2017 05:21:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current memset is using incorrect type of variable, causing the
upper-half of the strucutre to be left uninitialized and causing:

  ethernet/qlogic/qed/qed_init_fw_funcs.c: In function 'qed_set_rfs_mode_disable':
  ethernet/qlogic/qed/qed_init_fw_funcs.c:993:3: error: '*((void *)&ramline+4)' is used uninitialized in this function [-Werror=uninitialized]

Fixes: d51e4af5c209 ("qed: aRFS infrastructure support")
Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
Hi Arnd,

I don't see the original warning you've reported [probably due to
compiler differences], so other than via code reading I couldn't
actually test this. Can you please compile-test this one?

As mentioned in the original thread, I'll send the style-change
later to net-next.

Dave - please consider applying this to `net'.

Thanks,
Yuval
---

 drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
index 67200c5..0a8fde6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
@@ -983,7 +983,7 @@ void qed_set_rfs_mode_disable(struct qed_hwfn *p_hwfn,
 	memset(&camline, 0, sizeof(union gft_cam_line_union));
 	qed_wr(p_hwfn, p_ptt, PRS_REG_GFT_CAM + CAM_LINE_SIZE * pf_id,
 	       camline.cam_line_mapped.camline);
-	memset(&ramline, 0, sizeof(union gft_cam_line_union));
+	memset(&ramline, 0, sizeof(ramline));
 
 	for (i = 0; i < RAM_LINE_SIZE / REG_SIZE; i++) {
 		u32 hw_addr = PRS_REG_GFT_PROFILE_MASK_RAM;
-- 
1.9.3
