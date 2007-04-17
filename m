From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: [Patch driver tree] qeth: Remove usage of subsys.rwsem
Date: Tue, 17 Apr 2007 13:01:38 +0200
Message-ID: <20070417130138.37089b7b@gondolin.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Greg K-H <greg@kroah.com>, Frank Pavlic <fpavlic@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:38065 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753625AbXDQK7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 06:59:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

the current driver tree contains the removal of subsys.rwsem.
Unfortunately, this breaks qeth. However, it should be no problem to
fix the walking of the devices for /proc/qeth:

No need to take subsys.rwsem during walking the devices,
driver_find_devices() should already suffice.

Signed-off-by: Cornelia Huck <cornelia.huck@de.ibm.com>

---
 drivers/s390/net/qeth_proc.c |    2 --
 1 files changed, 2 deletions(-)

--- linux.orig/drivers/s390/net/qeth_proc.c
+++ linux/drivers/s390/net/qeth_proc.c
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
