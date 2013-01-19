From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 09/21] NTB: namespacecheck cleanups
Date: Sat, 19 Jan 2013 02:02:23 -0700
Message-ID: <1358586155-23322-10-git-send-email-jon.mason@intel.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declare ntb_bus_type static to remove it from name space, and remove
unused ntb_get_max_spads function.  Found via `make namespacecheck`.

Signed-off-by: Jon Mason <jon.mason@intel.com>
---
 drivers/ntb/ntb_hw.c        |   14 --------------
 drivers/ntb/ntb_transport.c |    2 +-
 2 files changed, 1 insertion(+), 15 deletions(-)

diff --git a/drivers/ntb/ntb_hw.c b/drivers/ntb/ntb_hw.c
index 2357c2d..18cb5dc 100644
--- a/drivers/ntb/ntb_hw.c
+++ b/drivers/ntb/ntb_hw.c
@@ -238,20 +238,6 @@ void ntb_unregister_transport(struct ntb_device *ndev)
 }
 
 /**
- * ntb_get_max_spads() - get the total scratch regs usable
- * @ndev: pointer to ntb_device instance
- *
- * This function returns the max 32bit scratchpad registers usable by the
- * upper layer.
- *
- * RETURNS: total number of scratch pad registers available
- */
-int ntb_get_max_spads(struct ntb_device *ndev)
-{
-	return ndev->limits.max_spads;
-}
-
-/**
  * ntb_write_local_spad() - write to the secondary scratchpad register
  * @ndev: pointer to ntb_device instance
  * @idx: index to the scratchpad register, 0 based
diff --git a/drivers/ntb/ntb_transport.c b/drivers/ntb/ntb_transport.c
index c0eca02..903a72e 100644
--- a/drivers/ntb/ntb_transport.c
+++ b/drivers/ntb/ntb_transport.c
@@ -212,7 +212,7 @@ static int ntb_client_remove(struct device *dev)
 	return 0;
 }
 
-struct bus_type ntb_bus_type = {
+static struct bus_type ntb_bus_type = {
 	.name = "ntb_bus",
 	.match = ntb_match_bus,
 	.probe = ntb_client_probe,
-- 
1.7.9.5
