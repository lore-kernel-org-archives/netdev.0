From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 07/29] ioat: fix type mismatch for ->dmacount
Date: Thu, 03 Sep 2009 19:31:05 -0700
Message-ID: <20090904023105.32667.76009.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932648AbZIDCbK@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

->dmacount tracks the sequence number of active descriptors.  It is
written to the DMACOUNT register to update the channel's view of pending
descriptors in the chain.  The register is 16-bits so ->dmacount should
be unsigned and 16-bit as well.  Also modify ->desccount to maintain
alignment.

This was never a problem in practice because we never compared dmacount
values, but this is a bug waiting to happen.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index 1226e35..9f0c853 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -102,8 +102,8 @@ struct ioat_dma_chan {
 	struct delayed_work work;
 
 	int pending;
-	int dmacount;
-	int desccount;
+	u16 dmacount;
+	u16 desccount;
 
 	struct ioatdma_device *device;
 	struct dma_chan common;
