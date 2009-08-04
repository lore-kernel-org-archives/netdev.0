From: David VomLehn <dvomlehn@cisco.com>
Subject: [PATCH 6/7 v1] initdev:kernel:SCSI asynchronous block init device
	notification
Date: Tue, 4 Aug 2009 15:15:18 -0700
Message-ID: <20090804221518.GA9362@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-usb@vger.kernel.org,
	greg@kroah.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933475AbZHDWPW@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In addition to the bus initdev synchronization, SCSI also starts asynchronous
threads with which we must synchronize.

Signed-off-by: David VomLehn <dvomlehn@cisco.com>
---
 drivers/scsi/sd.c     |    2 ++
 fs/partitions/check.c |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/scsi/sd.c b/drivers/scsi/sd.c
index 5616cd7..394235d 100644
--- a/drivers/scsi/sd.c
+++ b/drivers/scsi/sd.c
@@ -2005,6 +2005,7 @@ static void sd_probe_async(void *data, async_cookie_t cookie)
 
 	sd_printk(KERN_NOTICE, sdkp, "Attached SCSI %sdisk\n",
 		  sdp->removable ? "removable " : "");
+	initdev_probe_done(INITDEV_BLOCK_MASK);
 }
 
 /**
@@ -2090,6 +2091,7 @@ static int sd_probe(struct device *dev)
 
 	get_device(&sdp->sdev_gendev);
 
+	initdev_found(INITDEV_BLOCK_MASK);
 	async_schedule(sd_probe_async, sdkp);
 
 	return 0;
diff --git a/fs/partitions/check.c b/fs/partitions/check.c
index ea4e6cb..a0fa50c 100644
--- a/fs/partitions/check.c
+++ b/fs/partitions/check.c
@@ -512,6 +512,7 @@ exit:
 	while ((part = disk_part_iter_next(&piter)))
 		kobject_uevent(&part_to_dev(part)->kobj, KOBJ_ADD);
 	disk_part_iter_exit(&piter);
+	initdev_registered(INITDEV_BLOCK_TYPE);
 }
 
 int rescan_partitions(struct gendisk *disk, struct block_device *bdev)
