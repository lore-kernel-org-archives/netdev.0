From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 07/10] driver:megaraid: return -ENOMEM on allocation failure.
Date: Wed, 13 Sep 2017 13:02:16 +0530
Message-ID: <1505287939-14106-7-git-send-email-allen.lkml@gmail.com>
References: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
Cc: nouveau@lists.freedesktop.org, linux-crypto@vger.kernel.org,
        dri-devel@lists.freedesktop.org, MPT-FusionLinux.pdl@broadcom.com,
        linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        megaraidlinux.pdl@broadcom.com, target-devel@vger.kernel.org,
        linux-fbdev@vger.kernel.org, linux-btrfs@vger.kernel.org,
        Allen Pais <allen.lkml@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/scsi/megaraid/megaraid_mbox.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/scsi/megaraid/megaraid_mbox.c b/drivers/scsi/megaraid/megaraid_mbox.c
index ec3c438..b09a0a6 100644
--- a/drivers/scsi/megaraid/megaraid_mbox.c
+++ b/drivers/scsi/megaraid/megaraid_mbox.c
@@ -724,8 +724,8 @@ megaraid_init_mbox(adapter_t *adapter)
 	 * controllers
 	 */
 	raid_dev = kzalloc(sizeof(mraid_device_t), GFP_KERNEL);
-	if (raid_dev == NULL) return -1;
-
+	if (!raid_dev)
+		return -ENOMEM;
 
 	/*
 	 * Attach the adapter soft state to raid device soft state
-- 
2.7.4
