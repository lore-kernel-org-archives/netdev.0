From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH] scsi: bfa: Increase requested firmware version to 3.2.5.1
Date: Fri, 23 Dec 2016 14:01:28 -0800
Message-ID: <20161223220128.1226-1-bpoirier@suse.com>
Cc: Tim Ehlers <tehlers@gwdg.de>, Rasesh Mody <rasesh.mody@qlogic.com>,
        Anil Gurumurthy <anil.gurumurthy@qlogic.com>,
        Sudarsana Kalluru <sudarsana.kalluru@qlogic.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Martin K. Petersen" <martin.petersen@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:36599 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757291AbcLWWDF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 17:03:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bna & bfa firmware version 3.2.5.1 was submitted to linux-firmware on Tue
Feb 17 19:10:20 2015 -0500 in 0ab54ff1dc ("linux-firmware: Add QLogic BR
Series Adapter Firmware").

bna was updated to use the newer firmware on Thu, 19 Feb 2015 16:02:32
-0500 in 3f307c3d70 ("bna: Update the Driver and Firmware Version")

bfa was not updated. I presume this was an oversight but it broke support
for bfa+bna cards such as the following
	04:00.0 Fibre Channel [0c04]: Brocade Communications Systems, Inc.
		1010/1020/1007/1741 10Gbps CNA [1657:0014] (rev 01)
	04:00.1 Fibre Channel [0c04]: Brocade Communications Systems, Inc.
		1010/1020/1007/1741 10Gbps CNA [1657:0014] (rev 01)
	04:00.2 Ethernet controller [0200]: Brocade Communications Systems,
		Inc. 1010/1020/1007/1741 10Gbps CNA [1657:0014] (rev 01)
	04:00.3 Ethernet controller [0200]: Brocade Communications Systems,
		Inc. 1010/1020/1007/1741 10Gbps CNA [1657:0014] (rev 01)

Currently, if the bfa module is loaded first, bna fails to probe the
respective devices with
[  215.026787] bna: QLogic BR-series 10G Ethernet driver - version: 3.2.25.1
[  215.043707] bna 0000:04:00.2: bar0 mapped to ffffc90001fc0000, len 262144
[  215.060656] bna 0000:04:00.2: initialization failed err=1
[  215.073893] bna 0000:04:00.3: bar0 mapped to ffffc90002040000, len 262144
[  215.090644] bna 0000:04:00.3: initialization failed err=1

Whereas if bna is loaded first, bfa fails with
[  249.592109] QLogic BR-series BFA FC/FCOE SCSI driver - version: 3.2.25.0
[  249.610738] bfa 0000:04:00.0: Running firmware version is incompatible with the driver version
[  249.833513] bfa 0000:04:00.0: bfa init failed
[  249.833919] scsi host6: QLogic BR-series FC/FCOE Adapter, hwpath: 0000:04:00.0 driver: 3.2.25.0
[  249.841446] bfa 0000:04:00.1: Running firmware version is incompatible with the driver version
[  250.045449] bfa 0000:04:00.1: bfa init failed
[  250.045962] scsi host7: QLogic BR-series FC/FCOE Adapter, hwpath: 0000:04:00.1 driver: 3.2.25.0

Increase bfa's requested firmware version.
I only tested that all of the devices probe without error.

Cc: Rasesh Mody <rasesh.mody@qlogic.com>
Reported-by: Tim Ehlers <tehlers@gwdg.de>
Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 drivers/scsi/bfa/bfad.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/scsi/bfa/bfad.c b/drivers/scsi/bfa/bfad.c
index 9d253cb..e70410b 100644
--- a/drivers/scsi/bfa/bfad.c
+++ b/drivers/scsi/bfa/bfad.c
@@ -64,9 +64,9 @@ int		max_rport_logins = BFA_FCS_MAX_RPORT_LOGINS;
 u32	bfi_image_cb_size, bfi_image_ct_size, bfi_image_ct2_size;
 u32	*bfi_image_cb, *bfi_image_ct, *bfi_image_ct2;
 
-#define BFAD_FW_FILE_CB		"cbfw-3.2.3.0.bin"
-#define BFAD_FW_FILE_CT		"ctfw-3.2.3.0.bin"
-#define BFAD_FW_FILE_CT2	"ct2fw-3.2.3.0.bin"
+#define BFAD_FW_FILE_CB		"cbfw-3.2.5.1.bin"
+#define BFAD_FW_FILE_CT		"ctfw-3.2.5.1.bin"
+#define BFAD_FW_FILE_CT2	"ct2fw-3.2.5.1.bin"
 
 static u32 *bfad_load_fwimg(struct pci_dev *pdev);
 static void bfad_free_fwimg(void);
-- 
2.10.2
