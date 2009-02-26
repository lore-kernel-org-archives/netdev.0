From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH 5/7] I/OAT: set tcp_dma_copybreak to 256k for I/OAT ver.3
Date: Thu, 26 Feb 2009 11:05:17 +0100
Message-ID: <20090226100515.3615.70407.stgit@linux.site>
References: <20090226100327.3615.21419.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snakebyte@gmx.de, shannon.nelson@intel.com,
	jeffrey.t.krisher@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57832 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755495AbZBZKOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 05:14:00 -0500
In-Reply-To: <20090226100327.3615.21419.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upcoming server platforms from Intel based on the Nehalem performance
have significantly improved CPU based copy performance.
However, the DMA engine can still be effective at higher I/O sizes
for TCP traffic and at this time copybreak
should be set to 256k for TCP traffic only.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Jeff Kirsher <jeffrey.t.krisher@intel.com>
---

 drivers/dma/ioatdma.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/dma/ioatdma.h b/drivers/dma/ioatdma.h
index a3306d0..dcf8db5 100644
--- a/drivers/dma/ioatdma.h
+++ b/drivers/dma/ioatdma.h
@@ -135,12 +135,14 @@ static inline void ioat_set_tcp_copy_bre
 	#ifdef CONFIG_NET_DMA
 	switch (dev->version) {
 	case IOAT_VER_1_2:
-	case IOAT_VER_3_0:
 		sysctl_tcp_dma_copybreak = 4096;
 		break;
 	case IOAT_VER_2_0:
 		sysctl_tcp_dma_copybreak = 2048;
 		break;
+	case IOAT_VER_3_0:
+		sysctl_tcp_dma_copybreak = 262144;
+		break;
 	}
 	#endif
 }

