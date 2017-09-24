From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: rtl8822be: Keep array subscript no lower than zero
Date: Sat, 23 Sep 2017 19:36:04 -0500
Message-ID: <20170924003604.21518-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34996 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751389AbdIXAgK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 20:36:10 -0400
Received: by mail-oi0-f67.google.com with SMTP id r20so1649542oie.2
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2017 17:36:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kbuild test robot reports the following:
   drivers/staging//rtlwifi/phydm/phydm_dig.c: In function 'odm_pause_dig':
   drivers/staging//rtlwifi/phydm/phydm_dig.c:494:45: warning: array subscript is below array bounds [-Warray-bounds]
      odm_write_dig(dm, dig_tab->pause_dig_value[max_level]);

This condition is caused when a loop falls through. The fix is to pin
max_level to be >= 0.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
c: kbuild test robot <fengguang.wu@intel.com>
Fixes: 9ce99b04b5b82fdf11e4c76b60a5f82c1e541297 staging: r8822be: Add phydm mini driver
---
 drivers/staging/rtlwifi/phydm/phydm_dig.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/rtlwifi/phydm/phydm_dig.c b/drivers/staging/rtlwifi/phydm/phydm_dig.c
index 31a4f3fcad19..c88b9788363a 100644
--- a/drivers/staging/rtlwifi/phydm/phydm_dig.c
+++ b/drivers/staging/rtlwifi/phydm/phydm_dig.c
@@ -490,6 +490,8 @@ void odm_pause_dig(void *dm_void, enum phydm_pause_type pause_type,
 				break;
 		}
 
+		/* pin max_level to be >= 0 */
+		max_level = max_t(s8, 0, max_level);
 		/* write IGI of lower level */
 		odm_write_dig(dm, dig_tab->pause_dig_value[max_level]);
 		ODM_RT_TRACE(dm, ODM_COMP_DIG,
-- 
2.12.3
