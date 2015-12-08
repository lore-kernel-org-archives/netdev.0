From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 3/3] ser_gigaset: remove unnecessary kfree() calls from release method
Date: Tue,  8 Dec 2015 12:00:33 +0100 (CET)
Message-ID: <61b60d7eff05eddf305460f3dae2b80221f08aad.1449570042.git.tilman@imap.cc>
References: <cover.1449570042.git.tilman@imap.cc>
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	<syzkaller@googlegroups.com>, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	<gigaset307x-common@lists.sourceforge.net>,
	<linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1449570042.git.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

device->platform_data and platform_device->resource are never used
and remain NULL through their entire life. Drops the kfree() calls
for them from the device release method.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Reported-by: Paul Bolle <pebolle@tiscali.nl>
---
 drivers/isdn/gigaset/ser-gigaset.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index 2693cb2..b7e0329 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -375,13 +375,8 @@ static void gigaset_freecshw(struct cardstate *cs)
 
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
1.9.2.459.g68773ac
