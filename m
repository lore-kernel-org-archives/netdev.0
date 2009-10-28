From: Narendra K <Narendra_K@dell.com>
Subject: [PATCH]udev:Extend udev to support move events
Date: Wed, 28 Oct 2009 07:46:29 -0500
Message-ID: <20091028124627.GA20936@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, matt_domsch@dell.com,
	jordan_hargrave@dell.com, charles_rose@dell.com,
	sandeep_k_shandilya@dell.com, dannf@hp.com
To: linux-hotplug@vger.kernel.org
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As of now, udev does not support move events that are generated when
network interfaces are renamed. This patch extends udev to support move
events. With this patch udev would support rules like 

ACTION=="move", SUBSYSTEM=="net", PROGRAM="netif_id %k"

Signed-off-by: Narendra K <Narendra_K@dell.com>
---
 udev/udev-event.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/udev/udev-event.c b/udev/udev-event.c
index f4d7121..4a77753 100644
--- a/udev/udev-event.c
+++ b/udev/udev-event.c
@@ -647,6 +647,13 @@ exit_add:
 		goto exit;
 	}
 
+	/* handle "move" event */
+	if (strcmp(udev_device_get_subsystem(dev), "net") == 0 && strcmp(udev_device_get_action(dev), "move") == 0) {
+		udev_rules_apply_to_event(rules, event);
+		udev_device_update_db(dev);
+		goto exit;
+	}
+
 	/* remove device node */
 	if (major(udev_device_get_devnum(dev)) != 0 && strcmp(udev_device_get_action(dev), "remove") == 0) {
 		/* import database entry and delete it */
-- 

With regards,
Narendra K

