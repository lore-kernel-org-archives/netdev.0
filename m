From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v3 3/3] mptsas: use module_long_probe_init()
Date: Tue, 12 Aug 2014 15:28:27 -0700
Message-ID: <1407882507-325-4-git-send-email-mcgrof@do-not-panic.com>
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
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1407882507-325-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

Its reported that mptsas can at times take over 30 seconds
to recognize SCSI storage devices [0], this is done on the
driver's probe path. Use the the new module_long_probe_init()
to annotate this driver's probe is broken and require some love,
but makes the driver operational until that is fixed.

[0] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1276705

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
 drivers/message/fusion/mptsas.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/message/fusion/mptsas.c b/drivers/message/fusion/mptsas.c
index 0707fa2..c2bb72b 100644
--- a/drivers/message/fusion/mptsas.c
+++ b/drivers/message/fusion/mptsas.c
@@ -43,6 +43,7 @@
 */
 /*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/
 
+#include <linux/kthread.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/slab.h>
@@ -5439,5 +5440,5 @@ mptsas_exit(void)
 	mpt_deregister(mptsasDeviceResetCtx);
 }
 
-module_init(mptsas_init);
-module_exit(mptsas_exit);
+module_long_probe_init(mptsas_init);
+module_long_probe_exit(mptsas_exit);
-- 
2.0.3

