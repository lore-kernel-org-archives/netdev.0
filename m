From: Joe Perches <joe@perches.com>
Subject: [PATCH (sent originally to netdev)] device: Add dev_<level>_once
 variants
Date: Mon, 17 Nov 2014 18:18:22 -0800
Message-ID: <1416277102.29010.14.camel@perches.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416031715-32498-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5467C3BA.6090003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5467C3BA.6090003@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the equivalents to pr_<level>_once.

Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/device.h | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/include/linux/device.h b/include/linux/device.h
index ce1f2160..a1ee071 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -1118,6 +1118,41 @@ do {						     \
 })
 #endif
 
+#ifdef CONFIG_PRINTK
+#define dev_level_once(dev_level, dev, fmt, ...)			\
+do {									\
+	static bool __print_once __read_mostly;				\
+									\
+	if (!__print_once) {						\
+		__print_once = true;					\
+		dev_level(dev, fmt, ##__VA_ARGS__);			\
+	}								\
+} while (0)
+#else
+#define dev_level_once(dev_level, dev, fmt, ...)			\
+do {									\
+	if (0)								\
+		dev_level(dev, fmt, ##__VA_ARGS__);			\
+} while (0)
+#endif
+
+#define dev_emerg_once(dev, fmt, ...)					\
+	dev_level_once(dev_emerg, dev, fmt, ##__VA_ARGS__)
+#define dev_alert_once(dev, fmt, ...)					\
+	dev_level_once(dev_alert, dev, fmt, ##__VA_ARGS__)
+#define dev_crit_once(dev, fmt, ...)					\
+	dev_level_once(dev_crit, dev, fmt, ##__VA_ARGS__)
+#define dev_err_once(dev, fmt, ...)					\
+	dev_level_once(dev_err, dev, fmt, ##__VA_ARGS__)
+#define dev_warn_once(dev, fmt, ...)					\
+	dev_level_once(dev_warn, dev, fmt, ##__VA_ARGS__)
+#define dev_notice_once(dev, fmt, ...)					\
+	dev_level_once(dev_notice, dev, fmt, ##__VA_ARGS__)
+#define dev_info_once(dev, fmt, ...)					\
+	dev_level_once(dev_info, dev, fmt, ##__VA_ARGS__)
+#define dev_dbg_once(dev, fmt, ...)					\
+	dev_level_once(dev_info, dev, fmt, ##__VA_ARGS__)
+
 #define dev_level_ratelimited(dev_level, dev, fmt, ...)			\
 do {									\
 	static DEFINE_RATELIMIT_STATE(_rs,				\
