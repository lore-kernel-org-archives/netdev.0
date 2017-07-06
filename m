From: Shawn Lin <shawn.lin-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH] mwifiex: fix compile warning of unused variable
Date: Thu,  6 Jul 2017 15:50:33 +0800
Message-ID: <1499327433-70786-1-git-send-email-shawn.lin@rock-chips.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Xinming Hu <huxm-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Shawn Lin <shawn.lin-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: Amitkumar Karwar <amitkarwar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We got a compile warning shows below:

drivers/net/wireless/marvell/mwifiex/sdio.c: In function
'mwifiex_sdio_remove':
drivers/net/wireless/marvell/mwifiex/sdio.c:377:6: warning: variable
'ret' set but not used [-Wunused-but-set-variable]

Per the code, it didn't check if mwifiex_sdio_read_fw_status
finish successfully. We should at least check the return of
mwifiex_sdio_read_fw_status, otherwise the following check of
firmware_stat and adapter->mfg_mode is pointless as the device
is probably dead.

Signed-off-by: Shawn Lin <shawn.lin-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
---

 drivers/net/wireless/marvell/mwifiex/sdio.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index f81a006..fd5183c 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -390,7 +390,8 @@ static int mwifiex_check_winner_status(struct mwifiex_adapter *adapter)
 	mwifiex_dbg(adapter, INFO, "info: SDIO func num=%d\n", func->num);
 
 	ret = mwifiex_sdio_read_fw_status(adapter, &firmware_stat);
-	if (firmware_stat == FIRMWARE_READY_SDIO && !adapter->mfg_mode) {
+	if (!ret && firmware_stat == FIRMWARE_READY_SDIO &&
+	    !adapter->mfg_mode) {
 		mwifiex_deauthenticate_all(adapter);
 
 		priv = mwifiex_get_priv(adapter, MWIFIEX_BSS_ROLE_ANY);
-- 
1.9.1
