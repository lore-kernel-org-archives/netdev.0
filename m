From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [PATCH net-next] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Mon, 20 Jun 2016 05:20:55 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F92CD6858D@HASMSX110.ger.corp.intel.com>
References: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "zorik@annapurnalabs.com" <zorik@annapurnalabs.com>,
	"saeed@annapurnalabs.com" <saeed@annapurnalabs.com>,
	"alex@annapurnalabs.com" <alex@annapurnalabs.com>,
	"msw@amazon.com" <msw@amazon.com>,
	"aligouri@amazon.com" <aligouri@amazon.com>,
	"antoine.tenart@free-electrons.com"
	<antoine.tenart@free-electrons.com>,
	"Rosen, Rami" <rami.rosen@intel.com>
To: Netanel Belgazal <netanel@annapurnalabs.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davm@davemeloft.net" <davm@davemeloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40955 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751628AbcFTFdM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 01:33:12 -0400
In-Reply-To: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all, 

A very limited review below.

+
+	/* get capabilities of particular feature */
+	ENA_ADMIN_GET_FEATURE = 8,

Instead /* get capabilities  SHOULD BE:  /* set capabilities .....
+
+	/* get capabilities of particular feature */
+	ENA_ADMIN_SET_FEATURE = 9,
+
..


+int ena_com_set_hash_ctrl(struct ena_com_dev *ena_dev)
+{
+	struct ena_com_admin_queue *admin_queue = &ena_dev->admin_queue;
...

You set ret=-EINVAL, but you do not use this ret as you immediately return 0 in the next line, which is the end of the method. Either return ret or return -EINVAL.
+	if (unlikely(ret)) {
+		ena_trc_err("Failed to set hash input. error: %d\n", ret);
+		ret = -EINVAL;
+	}
+
+	return 0;
+}
+



+
+/* ena_com_set_mmio_read_mode - Enable/disable the mmio reg read mechanism
+ * @ena_dev: ENA communication layer struct


Instead realess_supported: SHOULD BE: readless_supported

+ * @realess_supported: readless mode (enable/disable)
+ */
+void ena_com_set_mmio_read_mode(struct ena_com_dev *ena_dev,
+				bool readless_supported);
+



+
+/* ena_com_create_io_queue - Create io queue.
+ * @ena_dev: ENA communication layer struct

Instead ena_com_create_io_ctx SHOULD BE: @ena_com_create_io_ctx

+ * ena_com_create_io_ctx - create context structure
+ *
+ * Create the submission and the completion queues.
+ *
+ * @return - 0 on success, negative value on failure.
+ */
+int ena_com_create_io_queue(struct ena_com_dev *ena_dev,
+			    struct ena_com_create_io_ctx *ctx);
+




+/* ena_com_admin_destroy - Destroy IO queue with the queue id - qid.
+ * @ena_dev: ENA communication layer struct

Missing: @qid

+ */
+void ena_com_destroy_io_queue(struct ena_com_dev *ena_dev, u16 qid);
+

Regards,
Rami Rosen
Intel Corporation
