From: Surendra Patil <surendra.tux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] Drivers:net:wireless:ti:wl1251: Fixed Sparse invalid assignment warning
Date: Tue,  4 Mar 2014 00:18:52 -0800
Message-ID: <1393921132-15950-1-git-send-email-surendra.tux@gmail.com>
Cc: pavel-+ZI9xUNit7I@public.gmane.org, pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org,
	surendra.tux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sparse warns about invalid assignment in
drivers/net/wireless/ti/wl1251/cmd.c:451:42: warning: invalid assignment: |=
drivers/net/wireless/ti/wl1251/cmd.c:451:42:    left side has type restricted __le16
drivers/net/wireless/ti/wl1251/cmd.c:451:42:    right side has type int
Hence type converted right side to __le16.

Signed-off-by: Surendra Patil <surendra.tux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/ti/wl1251/cmd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wl1251/cmd.c b/drivers/net/wireless/ti/wl1251/cmd.c
index 223649b..bf1fa18 100644
--- a/drivers/net/wireless/ti/wl1251/cmd.c
+++ b/drivers/net/wireless/ti/wl1251/cmd.c
@@ -448,7 +448,7 @@ int wl1251_cmd_scan(struct wl1251 *wl, u8 *ssid, size_t ssid_len,
 	 * Note: This bug may be caused by the fw's DTIM handling.
 	 */
 	if (is_zero_ether_addr(wl->bssid))
-		cmd->params.scan_options |= WL1251_SCAN_OPT_PRIORITY_HIGH;
+		cmd->params.scan_options |= cpu_to_le16(WL1251_SCAN_OPT_PRIORITY_HIGH);
 	cmd->params.num_channels = n_channels;
 	cmd->params.num_probe_requests = n_probes;
 	cmd->params.tx_rate = cpu_to_le16(1 << 1); /* 2 Mbps */
-- 
1.8.3.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
