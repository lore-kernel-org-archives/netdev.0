From: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] drivers/net/wireless/iwlegacy: adding check length for parameter
 buf
Date: Sun, 20 Jan 2013 17:53:54 +0800
Message-ID: <50FBBEB2.2000306@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


  the parameter 'const char *buf' may be not '\0' based string.
  so need check the length before use it.

additinal info:
  originally, it had the relative checking.
  but it was deleted when fix another issues (using strlcpy instead of
strncpy)
  and now, we need restore the checking (but still keep strlcpy)

Signed-off-by: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/iwlegacy/3945-mac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c
b/drivers/net/wireless/iwlegacy/3945-mac.c
index 050ce7c..71cdbac 100644
--- a/drivers/net/wireless/iwlegacy/3945-mac.c
+++ b/drivers/net/wireless/iwlegacy/3945-mac.c
@@ -3273,7 +3273,7 @@ il3945_store_measurement(struct device *d, struct
device_attribute *attr,

 	if (count) {
 		char *p = buffer;
-		strlcpy(buffer, buf, sizeof(buffer));
+		strlcpy(buffer, buf, min(sizeof(buffer), count));
 		channel = simple_strtoul(p, NULL, 0);
 		if (channel)
 			params.channel = channel;
-- 
1.7.10.4
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
