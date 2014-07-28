From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v2 1/4] driver core: move deferred probe add / remove helpers down a bit
Date: Mon, 28 Jul 2014 11:28:27 -0700
Message-ID: <1406572110-26823-2-git-send-email-mcgrof@do-not-panic.com>
References: <1406572110-26823-1-git-send-email-mcgrof@do-not-panic.com>
Cc: tiwai@suse.de, linux-kernel@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:36392 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbaG1S2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 14:28:41 -0400
In-Reply-To: <1406572110-26823-1-git-send-email-mcgrof@do-not-panic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Luis R. Rodriguez" <mcgrof@suse.com>

We need to do this if we want to use the trigger at a later point.
This change has introduces no functional changes.

Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Joseph Salisbury <joseph.salisbury@canonical.com>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Tim Gardner <tim.gardner@canonical.com>
Cc: Pierre Fersing <pierre-fersing@pierref.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Benjamin Poirier <bpoirier@suse.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>
Cc: Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>
Cc: Sreekanth Reddy <sreekanth.reddy@avagotech.com>
Cc: Abhijit Mahajan <abhijit.mahajan@avagotech.com>
Cc: Hariprasad S <hariprasad@chelsio.com>
Cc: Santosh Rastapur <santosh@chelsio.com>
Cc: MPT-FusionLinux.pdl@avagotech.com
Cc: linux-scsi@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 drivers/base/dd.c | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/base/dd.c b/drivers/base/dd.c
index e4ffbcf..9947c2e 100644
--- a/drivers/base/dd.c
+++ b/drivers/base/dd.c
@@ -109,26 +109,6 @@ static void deferred_probe_work_func(struct work_struct *work)
 }
 static DECLARE_WORK(deferred_probe_work, deferred_probe_work_func);
 
-static void driver_deferred_probe_add(struct device *dev)
-{
-	mutex_lock(&deferred_probe_mutex);
-	if (list_empty(&dev->p->deferred_probe)) {
-		dev_dbg(dev, "Added to deferred list\n");
-		list_add_tail(&dev->p->deferred_probe, &deferred_probe_pending_list);
-	}
-	mutex_unlock(&deferred_probe_mutex);
-}
-
-void driver_deferred_probe_del(struct device *dev)
-{
-	mutex_lock(&deferred_probe_mutex);
-	if (!list_empty(&dev->p->deferred_probe)) {
-		dev_dbg(dev, "Removed from deferred list\n");
-		list_del_init(&dev->p->deferred_probe);
-	}
-	mutex_unlock(&deferred_probe_mutex);
-}
-
 static bool driver_deferred_probe_enable = false;
 /**
  * driver_deferred_probe_trigger() - Kick off re-probing deferred devices
@@ -171,6 +151,26 @@ static void driver_deferred_probe_trigger(void)
 	queue_work(deferred_wq, &deferred_probe_work);
 }
 
+static void driver_deferred_probe_add(struct device *dev)
+{
+	mutex_lock(&deferred_probe_mutex);
+	if (list_empty(&dev->p->deferred_probe)) {
+		dev_dbg(dev, "Added to deferred list\n");
+		list_add_tail(&dev->p->deferred_probe, &deferred_probe_pending_list);
+	}
+	mutex_unlock(&deferred_probe_mutex);
+}
+
+void driver_deferred_probe_del(struct device *dev)
+{
+	mutex_lock(&deferred_probe_mutex);
+	if (!list_empty(&dev->p->deferred_probe)) {
+		dev_dbg(dev, "Removed from deferred list\n");
+		list_del_init(&dev->p->deferred_probe);
+	}
+	mutex_unlock(&deferred_probe_mutex);
+}
+
 /**
  * deferred_probe_initcall() - Enable probing of deferred devices
  *
-- 
2.0.1
