From: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] mwifiex: use is_broadcast_ether_addr() instead of memcmp()
Date: Fri, 24 Aug 2012 11:00:57 +0800
Message-ID: <CAPgLHd9YDVVJ+RMZTR4ubQy_cvMPYgWgFWpjpdUuAeu5B6T1Bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>

Using is_broadcast_ether_addr() instead of directly use
memcmp() to determine if the ethernet address is broadcast
address.

Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
---
 drivers/net/wireless/mwifiex/sta_cmd.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/sta_cmd.c b/drivers/net/wireless/mwifiex/sta_cmd.c
index df3a33c..45461ca 100644
--- a/drivers/net/wireless/mwifiex/sta_cmd.c
+++ b/drivers/net/wireless/mwifiex/sta_cmd.c
@@ -17,6 +17,8 @@
  * this warranty disclaimer.
  */
 
+#include <linux/etherdevice.h>
+
 #include "decl.h"
 #include "ioctl.h"
 #include "util.h"
@@ -551,7 +553,6 @@ mwifiex_cmd_802_11_key_material(struct mwifiex_private *priv,
 	struct host_cmd_tlv_mac_addr *tlv_mac;
 	u16 key_param_len = 0, cmd_size;
 	int ret = 0;
-	const u8 bc_mac[] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 
 	cmd->command = cpu_to_le16(HostCmd_CMD_802_11_KEY_MATERIAL);
 	key_material->action = cpu_to_le16(cmd_action);
@@ -593,7 +594,7 @@ mwifiex_cmd_802_11_key_material(struct mwifiex_private *priv,
 			/* set 0 when re-key */
 			key_material->key_param_set.key[1] = 0;
 
-		if (0 != memcmp(enc_key->mac_addr, bc_mac, sizeof(bc_mac))) {
+		if (!is_broadcast_ether_addr(enc_key->mac_addr)) {
 			/* WAPI pairwise key: unicast */
 			key_material->key_param_set.key_info |=
 				cpu_to_le16(KEY_UNICAST);

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
