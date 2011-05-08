From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 002/115] sysctl: parport: reorder .child assignments to simplify review
Date: Mon,  9 May 2011 00:38:14 +0200
Message-ID: <1304894407-32201-3-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 drivers/parport/procfs.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/parport/procfs.c b/drivers/parport/procfs.c
index 89b8b71..edeb012 100644
--- a/drivers/parport/procfs.c
+++ b/drivers/parport/procfs.c
@@ -437,16 +437,17 @@ int parport_proc_register(struct parport *port)
 		t->vars[i].extra1 = port;
 
 	t->vars[0].data = &port->spintime;
-	t->vars[5].child = t->device_dir;
 	
 	for (i = 0; i < 5; i++)
 		t->vars[6 + i].extra2 = &port->probe_info[i];
 
 	t->port_dir[0].procname = port->name;
 
-	t->port_dir[0].child = t->vars;
-	t->parport_dir[0].child = t->port_dir;
 	t->dev_dir[0].child = t->parport_dir;
+	t->parport_dir[0].child = t->port_dir;
+	t->port_dir[0].child = t->vars;
+	t->vars[5].child = t->device_dir;
+	/* vars[5] = PARPORT_DEVICES_ROOT_DIR => .procname = 'devices' */
 
 	t->sysctl_header = register_sysctl_table(t->dev_dir);
 	if (t->sysctl_header == NULL) {
@@ -478,14 +479,15 @@ int parport_device_proc_register(struct pardevice *device)
 		return -ENOMEM;
 	memcpy(t, &parport_device_sysctl_template, sizeof(*t));
 
+	t->port_dir[0].procname = port->name;
+	t->device_dir[0].procname = device->name;
+
 	t->dev_dir[0].child = t->parport_dir;
 	t->parport_dir[0].child = t->port_dir;
-	t->port_dir[0].procname = port->name;
 	t->port_dir[0].child = t->devices_root_dir;
 	t->devices_root_dir[0].child = t->device_dir;
-
-	t->device_dir[0].procname = device->name;
 	t->device_dir[0].child = t->vars;
+
 	t->vars[0].data = &device->timeslice;
 
 	t->sysctl_header = register_sysctl_table(t->dev_dir);
-- 
1.7.5.134.g1c08b
