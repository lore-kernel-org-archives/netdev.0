From: "Fu, Zhonghui" <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCH v2] net/wireless: enable wiphy device to suspend/resume asynchronously
Date: Sat, 19 Sep 2015 10:40:14 +0800
Message-ID: <55FCCB0E.3000807@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Now, PM core supports asynchronous suspend/resume mode for devices
during system suspend/resume, and the power state transition of one
device may be completed in separate kernel thread. PM core ensures
all power state transition timing dependency between devices. This
patch enables wiphy device to suspend/resume asynchronously. This can
take advantage of multicore and improve system suspend/resume speed.

Signed-off-by: Zhonghui Fu <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
---
Changes in v2:
- Amend commit message.

 net/wireless/core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/wireless/core.c b/net/wireless/core.c
index 3893409..f223026 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -419,6 +419,7 @@ use_default_name:
 	device_initialize(&rdev->wiphy.dev);
 	rdev->wiphy.dev.class = &ieee80211_class;
 	rdev->wiphy.dev.platform_data = rdev;
+	device_enable_async_suspend(&rdev->wiphy.dev);
 
 	INIT_LIST_HEAD(&rdev->destroy_list);
 	spin_lock_init(&rdev->destroy_list_lock);
-- 1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
