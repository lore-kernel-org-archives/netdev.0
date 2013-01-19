From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 02/21] NTB: Handle ntb client device probes without present hardware
Date: Sat, 19 Jan 2013 02:02:16 -0700
Message-ID: <1358586155-23322-3-git-send-email-jon.mason@intel.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Attempts to probe client ntb drivers without ntb hardware present will
result in null pointer dereference due to the lack of the ntb bus device
being registers.  Check to see if this is the case, and fail all calls
by the clients registering their drivers.

Signed-off-by: Jon Mason <jon.mason@intel.com>
---
 drivers/ntb/ntb_transport.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/ntb/ntb_transport.c b/drivers/ntb/ntb_transport.c
index 250190f..1d17857 100644
--- a/drivers/ntb/ntb_transport.c
+++ b/drivers/ntb/ntb_transport.c
@@ -288,6 +288,9 @@ int ntb_register_client_dev(char *device_name)
 	struct ntb_transport *nt;
 	int rc;
 
+	if (list_empty(&ntb_transport_list))
+		return -ENODEV;
+
 	list_for_each_entry(nt, &ntb_transport_list, entry) {
 		struct device *dev;
 
@@ -336,6 +339,9 @@ int ntb_register_client(struct ntb_client *drv)
 {
 	drv->driver.bus = &ntb_bus_type;
 
+	if (list_empty(&ntb_transport_list))
+		return -ENODEV;
+
 	return driver_register(&drv->driver);
 }
 EXPORT_SYMBOL_GPL(ntb_register_client);
-- 
1.7.9.5
