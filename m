From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] bluetooth: Convert bt_<level> logging functions to
 return void
Date: Mon, 22 Sep 2014 11:17:41 -0700
Message-ID: <1411409861.2952.57.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No caller or macro uses the return value so make all
the functions return void.

Signed-off-by: Joe Perches <joe@perches.com>
---
This change is associated to a desire to eventually
change printk to return void.

 include/net/bluetooth/bluetooth.h |  4 ++--
 net/bluetooth/lib.c               | 14 ++++----------
 2 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 7e666d0..58695ff 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -120,9 +120,9 @@ struct bt_voice {
 #define BT_RCVMTU		13
 
 __printf(1, 2)
-int bt_info(const char *fmt, ...);
+void bt_info(const char *fmt, ...);
 __printf(1, 2)
-int bt_err(const char *fmt, ...);
+void bt_err(const char *fmt, ...);
 
 #define BT_INFO(fmt, ...)	bt_info(fmt "\n", ##__VA_ARGS__)
 #define BT_ERR(fmt, ...)	bt_err(fmt "\n", ##__VA_ARGS__)
diff --git a/net/bluetooth/lib.c b/net/bluetooth/lib.c
index 941ad75..b36bc04 100644
--- a/net/bluetooth/lib.c
+++ b/net/bluetooth/lib.c
@@ -135,40 +135,34 @@ int bt_to_errno(__u16 code)
 }
 EXPORT_SYMBOL(bt_to_errno);
 
-int bt_info(const char *format, ...)
+void bt_info(const char *format, ...)
 {
 	struct va_format vaf;
 	va_list args;
-	int r;
 
 	va_start(args, format);
 
 	vaf.fmt = format;
 	vaf.va = &args;
 
-	r = pr_info("%pV", &vaf);
+	pr_info("%pV", &vaf);
 
 	va_end(args);
-
-	return r;
 }
 EXPORT_SYMBOL(bt_info);
 
-int bt_err(const char *format, ...)
+void bt_err(const char *format, ...)
 {
 	struct va_format vaf;
 	va_list args;
-	int r;
 
 	va_start(args, format);
 
 	vaf.fmt = format;
 	vaf.va = &args;
 
-	r = pr_err("%pV", &vaf);
+	pr_err("%pV", &vaf);
 
 	va_end(args);
-
-	return r;
 }
 EXPORT_SYMBOL(bt_err);
