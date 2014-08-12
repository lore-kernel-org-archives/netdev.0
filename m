From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v3 2/3] cxgb4: use module_long_probe_init()
Date: Tue, 12 Aug 2014 15:28:26 -0700
Message-ID: <1407882507-325-3-git-send-email-mcgrof@do-not-panic.com>
References: <1407882507-325-1-git-send-email-mcgrof@do-not-panic.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407882507-325-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

cxgb4 probe can take up to over 1 minute when the firmware is
is written and installed on the device, even after this the device
driver still does some device probing and can take quite a bit.
This driver needs fixing but right now it simply wont' work on
some systems. Use the new module_long_probe_init() to annotate
this driver's probe is broken and require some love, but makes
the driver operational until that is fixed.

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
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 36ebbda..5d8231d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -34,6 +34,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/kthread.h>
 #include <linux/bitmap.h>
 #include <linux/crc32.h>
 #include <linux/ctype.h>
@@ -6815,5 +6816,5 @@ static void __exit cxgb4_cleanup_module(void)
 	destroy_workqueue(workq);
 }
 
-module_init(cxgb4_init_module);
-module_exit(cxgb4_cleanup_module);
+module_long_probe_init(cxgb4_init_module);
+module_long_probe_exit(cxgb4_cleanup_module);
-- 
2.0.3
