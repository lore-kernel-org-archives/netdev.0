From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Subject: [PATCH] net:liquidio: use kmemdup
Date: Thu, 19 May 2016 19:22:49 +0530
Message-ID: <1463665972-16451-1-git-send-email-falakreyaz@gmail.com>
Cc: Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use kmemdup when some other buffer is immediately copied into allocated
region. It replaces call to allocation followed by memcpy, by a single
call to kmemdup.

Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_device.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index f67641a..8e23e3f 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -602,12 +602,10 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 	snprintf(oct->fw_info.liquidio_firmware_version, 32, "LIQUIDIO: %s",
 		 h->version);
 
-	buffer = kmalloc(size, GFP_KERNEL);
+	buffer = kmemdup(data, size, GFP_KERNEL);
 	if (!buffer)
 		return -ENOMEM;
 
-	memcpy(buffer, data, size);
-
 	p = buffer + sizeof(struct octeon_firmware_file_header);
 
 	/* load all images */
-- 
1.9.1
