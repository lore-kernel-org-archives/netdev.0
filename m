From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 083/115] sysctl: single subheader path: dev/parport/PORT/devices/DEVICE/
Date: Mon,  9 May 2011 00:39:35 +0200
Message-ID: <1304894407-32201-84-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41043 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932588Ab1EHWmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:42:07 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch was not tested!

Parport registers tables under these paths:
	dev/parport/default/
	dev/parport/PORT/
	dev/parport/PORT/devices/
	dev/parport/PORT/devices/DEVICE/

Nothing else is registered below dev/parport/PORT/devices/DEVICE/ and
I assume device names are unique (if they are not this patch is
invalid), so we can skip name checks for the 'DEVICE' directory.

This will have a positive performance impact when there are many
devices registered on the same port.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 drivers/parport/procfs.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/parport/procfs.c b/drivers/parport/procfs.c
index 3bb5bed..9c48946 100644
--- a/drivers/parport/procfs.c
+++ b/drivers/parport/procfs.c
@@ -442,7 +442,12 @@ int parport_device_proc_register(struct pardevice *device)
 		{ .procname = "parport" },
 		{ .procname = port->name },
 		{ .procname = "devices" },
-		{ .procname = device->name },
+		{
+			.procname = device->name,
+			/* skip duplicate name check; we're registering
+			 * just one subheader for this directory */
+			.has_just_one_subheader = 1,
+		},
 		{  },
 	};
 
-- 
1.7.5.134.g1c08b

