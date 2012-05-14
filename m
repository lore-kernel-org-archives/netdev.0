From: Hiroshi DOYU <hdoyu-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] driver core: Add dev_*_ratelimited() family
Date: Mon, 14 May 2012 10:47:57 +0300
Message-ID: <1336981680-15297-1-git-send-email-hdoyu@nvidia.com>
References: <20120514.104512.775373956832728793.hdoyu@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, <linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <hdoyu-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120514.104512.775373956832728793.hdoyu-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add dev_*_ratelimited() family, dev_* version of pr_*_ratelimited().

Using Joe Perches's proposal/implementation.

Signed-off-by: Hiroshi DOYU <hdoyu-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 include/linux/device.h |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/include/linux/device.h b/include/linux/device.h
index 8b9d03a..d3aafdb 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -23,6 +23,7 @@
 #include <linux/mutex.h>
 #include <linux/pm.h>
 #include <linux/atomic.h>
+#include <linux/ratelimit.h>
 #include <asm/device.h>
 
 struct device;
@@ -937,6 +938,32 @@ int _dev_info(const struct device *dev, const char *fmt, ...)
 
 #endif
 
+#define dev_level_ratelimited(dev_level, dev, fmt, ...)			\
+do {									\
+	static DEFINE_RATELIMIT_STATE(_rs,				\
+				      DEFAULT_RATELIMIT_INTERVAL,	\
+				      DEFAULT_RATELIMIT_BURST);		\
+	if (__ratelimit(&_rs))						\
+		dev_level(dev, fmt, ##__VA_ARGS__);			\
+} while (0)
+
+#define dev_emerg_ratelimited(dev, fmt, ...)				\
+	dev_level_ratelimited(dev_emerg, dev, fmt, ##__VA_ARGS__)
+#define dev_alert_ratelimited(dev, fmt, ...)				\
+	dev_level_ratelimited(dev_alert, dev, fmt, ##__VA_ARGS__)
+#define dev_crit_ratelimited(dev, fmt, ...)				\
+	dev_level_ratelimited(dev_crit, dev, fmt, ##__VA_ARGS__)
+#define dev_err_ratelimited(dev, fmt, ...)				\
+	dev_level_ratelimited(dev_err, dev, fmt, ##__VA_ARGS__)
+#define dev_warn_ratelimited(dev, fmt, ...)				\
+	dev_level_ratelimited(dev_warn, dev, fmt, ##__VA_ARGS__)
+#define dev_notice_ratelimited(dev, fmt, ...)				\
+	dev_level_ratelimited(dev_notice, dev, fmt, ##__VA_ARGS__)
+#define dev_info_ratelimited(dev, fmt, ...)				\
+	dev_level_ratelimited(dev_info, dev, fmt, ##__VA_ARGS__)
+#define dev_dbg_ratelimited(dev, fmt, ...)				\
+	dev_level_ratelimited(dev_dbg, dev, fmt, ##__VA_ARGS__)
+
 /*
  * Stupid hackaround for existing uses of non-printk uses dev_info
  *
-- 
1.7.5.4
