From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 16/31] net/cavium/liquidio: use kmemdup rather than duplicating
 its implementation
Date: Fri, 07 Aug 2015 09:59:22 +0200
Message-ID: <1438934377-4922-17-git-send-email-a.hajda@samsung.com>
References: <1438934377-4922-1-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Andrzej Hajda <a.hajda@samsung.com>, linux-arm-kernel@lists.infradead.org,
 Marek Szyprowski <m.szyprowski@samsung.com>
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
 Satanand Burla <satananda.burla@caviumnetworks.com>,
 Felix Manlunas <felix.manlunas@caviumnetworks.com>,
 Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
 Sunil Goutham <sgoutham@cavium.com>, Robert Richter <rric@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-reply-to: <1438934377-4922-1-git-send-email-a.hajda@samsung.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The patch was generated using fixed coccinelle semantic patch
scripts/coccinelle/api/memdup.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2014320

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
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
