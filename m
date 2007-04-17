From: <gregkh@suse.de>
Subject: patch qeth-remove-usage-of-subsys_rwsem.patch added to gregkh-2.6 tree
Date: Tue, 17 Apr 2007 09:52:29 -0700
Message-ID: <20070417165444.E6072D4D35B@imap.suse.de>
References: <20070417130138.37089b7b@gondolin.boeblingen.de.ibm.com>
To: cornelia.huck@de.ibm.com, fpavlic@de.ibm.com, greg@kroah.com,
	gregkh@suse.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:58823 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031187AbXDQQyr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 12:54:47 -0400
In-Reply-To: <20070417130138.37089b7b@gondolin.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is a note to let you know that I've just added the patch titled

     Subject: qeth: Remove usage of subsys.rwsem

to my gregkh-2.6 tree.  Its filename is

     qeth-remove-usage-of-subsys_rwsem.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


>From cornelia.huck@de.ibm.com  Tue Apr 17 09:44:49 2007
From: Cornelia Huck <cornelia.huck@de.ibm.com>
Date: Tue, 17 Apr 2007 13:01:38 +0200
Subject: qeth: Remove usage of subsys.rwsem
To: Greg K-H <greg@kroah.com>, Frank Pavlic <fpavlic@de.ibm.com>
Cc: Linux Netdev List <netdev@vger.kernel.org>
Message-ID: <20070417130138.37089b7b@gondolin.boeblingen.de.ibm.com>

the current driver tree contains the removal of subsys.rwsem.
Unfortunately, this breaks qeth. However, it should be no problem to
fix the walking of the devices for /proc/qeth:

No need to take subsys.rwsem during walking the devices,
driver_find_devices() should already suffice.

Signed-off-by: Cornelia Huck <cornelia.huck@de.ibm.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/s390/net/qeth_proc.c |    2 --
 1 file changed, 2 deletions(-)

--- a/drivers/s390/net/qeth_proc.c
+++ b/drivers/s390/net/qeth_proc.c
@@ -37,7 +37,6 @@ qeth_procfile_seq_start(struct seq_file 
 	struct device *dev = NULL;
 	loff_t nr = 0;
 
-	down_read(&qeth_ccwgroup_driver.driver.bus->subsys.rwsem);
 	if (*offset == 0)
 		return SEQ_START_TOKEN;
 	while (1) {
@@ -53,7 +52,6 @@ qeth_procfile_seq_start(struct seq_file 
 static void
 qeth_procfile_seq_stop(struct seq_file *s, void* it)
 {
-	up_read(&qeth_ccwgroup_driver.driver.bus->subsys.rwsem);
 }
 
 static void *


Patches currently in gregkh-2.6 which might be from cornelia.huck@de.ibm.com are

driver/driver-core-per-subsystem-multithreaded-probing.patch
driver/driver-core-don-t-fail-attaching-the-device-if-it-cannot-be-bound.patch
driver/driver-core-suppress-uevents-via-filter.patch
driver/driver-core-switch-firmware_class-to-uevent_suppress.patch
driver/uevent-use-add_uevent_var-instead-of-open-coding-it.patch
driver/sysfs-add-sysfs_dirent-s_name.patch
driver/sysfs-add-sysfs_dirent-s_parent.patch
driver/sysfs-consolidate-sysfs_dirent-creation-functions.patch
driver/sysfs-fix-error-handling-in-binattr-write.patch
driver/sysfs-fix-i_ino-handling-in-sysfs.patch
driver/sysfs-flatten-cleanup-paths-in-sysfs_add_link-and-create_dir.patch
driver/sysfs-implement-bin_buffer.patch
driver/sysfs-implement-kobj_sysfs_assoc_lock.patch
driver/sysfs-make-sysfs_dirent-s_element-a-union.patch
driver/sysfs-move-release_sysfs_dirent-to-dir.c.patch
driver/sysfs-reimplement-symlink-using-sysfs_dirent-tree.patch
driver/sysfs-implement-sysfs_dirent-active-reference-and-immediate-disconnect.patch
driver/sysfs-kill-attribute-file-orphaning.patch
driver/sysfs-kill-unnecessary-attribute-owner.patch
driver/sysfs-make-lockdep-ignore-s_active.patch
driver/kobject-kobject_add-reference-leak.patch
driver/qeth-remove-usage-of-subsys_rwsem.patch
