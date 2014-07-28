From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH 2/3] cxgb4: ask for deferred probe
Date: Mon, 28 Jul 2014 07:34:26 -0700
Message-ID: <1406558067-25308-2-git-send-email-mcgrof@do-not-panic.com>
References: <1406558067-25308-1-git-send-email-mcgrof@do-not-panic.com>
Cc: linux-kernel@vger.kernel.org,
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
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36888 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732AbaG1Oek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 10:34:40 -0400
In-Reply-To: <1406558067-25308-1-git-send-email-mcgrof@do-not-panic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Luis R. Rodriguez" <mcgrof@suse.com>

cxgb4 probe can take up to over 1 minute when the firmware is
is written and installed on the device. Use the new delayed probe
preference so that cxgb4 gets probed on the deferred workqueue.
Without this devices that require the update on firmware will fail
on probe.

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
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 6b11fde..bb5daaf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -6400,6 +6400,9 @@ static void remove_one(struct pci_dev *pdev)
 }
 
 static struct pci_driver cxgb4_driver = {
+	.driver = {
+		.delay_probe = true,
+	},
 	.name     = KBUILD_MODNAME,
 	.id_table = cxgb4_pci_tbl,
 	.probe    = init_one,
-- 
2.0.1
