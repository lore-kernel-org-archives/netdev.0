From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30 3/5] cxgb3: use resource_size_t for mmio declarations
Date: Thu, 26 Mar 2009 19:39:19 -0700
Message-ID: <20090327023919.32137.81488.stgit@speedy5>
References: <20090327023909.32137.93884.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:31295 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755630AbZC0CjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 22:39:22 -0400
In-Reply-To: <20090327023909.32137.93884.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Use resource_size_t to declare mmio start and len variables.
Print PEX error register after EEH resumed.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 8ad5f32..e2b1193 100755
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2871,6 +2871,9 @@ static void t3_io_resume(struct pci_dev *pdev)
 {
 	struct adapter *adapter = pci_get_drvdata(pdev);
 
+	CH_ALERT(adapter, "adapter recovering, PEX ERR 0x%x\n",
+		 t3_read_reg(adapter, A_PCIE_PEX_ERR));
+
 	t3_resume_ports(adapter);
 }
 
@@ -3003,7 +3006,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 	static int version_printed;
 
 	int i, err, pci_using_dac = 0;
-	unsigned long mmio_start, mmio_len;
+	resource_size_t mmio_start, mmio_len;
 	const struct adapter_info *ai;
 	struct adapter *adapter = NULL;
 	struct port_info *pi;

