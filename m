From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH 4/4] ser_gigaset: remove unnecessary kfree() calls from release method
Date: Tue, 15 Dec 2015 18:11:31 +0100
Message-ID: <1450199491-30471-5-git-send-email-pebolle@tiscali.nl>
References: <1450199491-30471-1-git-send-email-pebolle@tiscali.nl>
Cc: Tilman Schmidt <tilman@imap.cc>, Alan Cox <alan@linux.intel.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Peter Hurley <peter@hurleysoftware.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450199491-30471-1-git-send-email-pebolle@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>

device->platform_data and platform_device->resource are never used
and remain NULL through their entire life. Drops the kfree() calls
for them from the device release method.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
 drivers/isdn/gigaset/ser-gigaset.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index 635baaf34e95..2a506fe0c8a4 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -373,13 +373,8 @@ static void gigaset_freecshw(struct cardstate *cs)
 
 static void gigaset_device_release(struct device *dev)
 {
-	struct platform_device *pdev = to_platform_device(dev);
 	struct cardstate *cs = dev_get_drvdata(dev);
 
-	/* adapted from platform_device_release() in drivers/base/platform.c */
-	kfree(dev->platform_data);
-	kfree(pdev->resource);
-
 	if (!cs)
 		return;
 	dev_set_drvdata(dev, NULL);
-- 
2.4.3
