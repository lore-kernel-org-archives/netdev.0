From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] wl1251: Remove unused function
Date: Sun,  4 Jan 2015 16:43:52 +0100
Message-ID: <1420386232-12344-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	=?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>,
	David Gnedt <david.gnedt@davizone.at>,
	George Spelvin <linux@horizon.com>,
	Surendra Patil <surendra.tux@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@adurom.com>, Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the function wl1251_cmd_read_memory() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/wireless/ti/wl1251/cmd.c |   40 ----------------------------------
 drivers/net/wireless/ti/wl1251/cmd.h |    2 --
 2 files changed, 42 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/cmd.c b/drivers/net/wireless/ti/wl1251/cmd.c
index ede31f0..26f4d74 100644
--- a/drivers/net/wireless/ti/wl1251/cmd.c
+++ b/drivers/net/wireless/ti/wl1251/cmd.c
@@ -346,46 +346,6 @@ out:
 	return ret;
 }
 
-int wl1251_cmd_read_memory(struct wl1251 *wl, u32 addr, void *answer,
-			   size_t len)
-{
-	struct cmd_read_write_memory *cmd;
-	int ret = 0;
-
-	wl1251_debug(DEBUG_CMD, "cmd read memory");
-
-	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
-	if (!cmd) {
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	WARN_ON(len > MAX_READ_SIZE);
-	len = min_t(size_t, len, MAX_READ_SIZE);
-
-	cmd->addr = addr;
-	cmd->size = len;
-
-	ret = wl1251_cmd_send(wl, CMD_READ_MEMORY, cmd, sizeof(*cmd));
-	if (ret < 0) {
-		wl1251_error("read memory command failed: %d", ret);
-		goto out;
-	}
-
-	/* the read command got in, we can now read the answer */
-	wl1251_mem_read(wl, wl->cmd_box_addr, cmd, sizeof(*cmd));
-
-	if (cmd->header.status != CMD_STATUS_SUCCESS)
-		wl1251_error("error in read command result: %d",
-			     cmd->header.status);
-
-	memcpy(answer, cmd->value, len);
-
-out:
-	kfree(cmd);
-	return ret;
-}
-
 int wl1251_cmd_template_set(struct wl1251 *wl, u16 cmd_id,
 			    void *buf, size_t buf_len)
 {
diff --git a/drivers/net/wireless/ti/wl1251/cmd.h b/drivers/net/wireless/ti/wl1251/cmd.h
index d824ff9..5f35430 100644
--- a/drivers/net/wireless/ti/wl1251/cmd.h
+++ b/drivers/net/wireless/ti/wl1251/cmd.h
@@ -40,8 +40,6 @@ int wl1251_cmd_data_path_tx(struct wl1251 *wl, u8 channel, bool enable);
 int wl1251_cmd_join(struct wl1251 *wl, u8 bss_type, u8 channel,
 		    u16 beacon_interval, u8 dtim_interval);
 int wl1251_cmd_ps_mode(struct wl1251 *wl, u8 ps_mode);
-int wl1251_cmd_read_memory(struct wl1251 *wl, u32 addr, void *answer,
-			   size_t len);
 int wl1251_cmd_template_set(struct wl1251 *wl, u16 cmd_id,
 			    void *buf, size_t buf_len);
 int wl1251_cmd_scan(struct wl1251 *wl, u8 *ssid, size_t ssid_len,
-- 
1.7.10.4
