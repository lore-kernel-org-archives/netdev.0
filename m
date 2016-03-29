From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [PATCH] net: ena: Add a driver for Amazon Elastic Network
 Adapters (ENA)
Date: Tue, 29 Mar 2016 15:06:28 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F92CBE25FC@HASMSX110.ger.corp.intel.com>
References: <1458039006-19956-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"antoine.tenart@free-electrons.com"
	<antoine.tenart@free-electrons.com>,
	"Rosen, Rami" <rami.rosen@intel.com>
To: Netanel Belgazal <netanel@annapurnalabs.com>,
	"zorik@annapurnalabs.com" <zorik@annapurnalabs.com>,
	"saeed@annapurnalabs.com" <saeed@annapurnalabs.com>,
	"alex@annapurnalabs.com" <alex@annapurnalabs.com>,
	"msw@amazon.com" <msw@amazon.com>,
	"aliguori@amazon.com" <aliguori@amazon.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458039006-19956-1-git-send-email-netanel@annapurnalabs.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Netanel,

+into 5 levels and assignes interrupt delay value to each level.
Should be: assigns

+The ENA device AQ and AENQ are allocated on probe and freed ontermination.
Should be: on termination.

+	/* commit previously loaded firmare */
Should be: firmware

+static int ena_com_hash_key_destroy(struct ena_com_dev *ena_dev)
+{
+	struct ena_rss *rss = &ena_dev->rss;
+
+	if (rss->hash_key)
+		dma_free_coherent(ena_dev->dmadev,
+				  sizeof(*rss->hash_key),
+				  rss->hash_key,
+				  rss->hash_key_dma_addr);
+	rss->hash_key = NULL;
+	return 0;
+}

This method always returns 0.

+static int ena_com_hash_ctrl_init(struct ena_com_dev *ena_dev)
+{
+	struct ena_rss *rss = &ena_dev->rss;
+
+	rss->hash_ctrl = dma_alloc_coherent(ena_dev->dmadev,
+					    sizeof(*rss->hash_ctrl),
+					    &rss->hash_ctrl_dma_addr,
+					    GFP_KERNEL | __GFP_ZERO);
+
+	return 0;
+}
+

This method also always returns 0.


+static int ena_com_hash_ctrl_destroy(struct ena_com_dev *ena_dev)
+{
+	struct ena_rss *rss = &ena_dev->rss;
+
+	if (rss->hash_ctrl)
+		dma_free_coherent(ena_dev->dmadev,
+				  sizeof(*rss->hash_ctrl),
+				  rss->hash_ctrl,
+				  rss->hash_ctrl_dma_addr);
+	rss->hash_ctrl = NULL;
+
+	return 0;
+}
+

This method also always returns 0.

+static int ena_com_indirect_table_destroy(struct ena_com_dev *ena_dev)
+{
+	struct ena_rss *rss = &ena_dev->rss;
+	size_t tbl_size = (1 << rss->tbl_log_size) *
+		sizeof(struct ena_admin_rss_ind_table_entry);
+
+	if (rss->rss_ind_tbl)
+		dma_free_coherent(ena_dev->dmadev,
+				  tbl_size,
+				  rss->rss_ind_tbl,
+				  rss->rss_ind_tbl_dma_addr);
+	rss->rss_ind_tbl = NULL;
+
+	if (rss->host_rss_ind_tbl)
+		devm_kfree(ena_dev->dmadev, rss->host_rss_ind_tbl);
+	rss->host_rss_ind_tbl = NULL;
+
+	return 0;
+}

This method also always returns 0.

+int ena_com_rss_destroy(struct ena_com_dev *ena_dev)
+{
+	ena_com_indirect_table_destroy(ena_dev);
+	ena_com_hash_key_destroy(ena_dev);
+	ena_com_hash_ctrl_destroy(ena_dev);
+
+	memset(&ena_dev->rss, 0x0, sizeof(ena_dev->rss));
+
+	return 0;
+}

This method also always returns 0.

Regards,
Rami Rosen
Intel Corporation
