From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next 10/14] Fix myricom/myri10ge
Date: Tue, 19 Jun 2012 18:14:04 +0300
Message-ID: <1340118848-30978-11-git-send-email-yuvalmin@broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Jon Mason" <mason@myri.com>, "Andrew Gallatin" <gallatin@myri.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4223 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754143Ab2FSPQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:16:37 -0400
In-Reply-To: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Jon Mason <mason@myri.com>
Cc: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 90153fc..70c132d 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -3775,7 +3775,7 @@ static void myri10ge_probe_slices(struct myri10ge_priv *mgp)
 
 	mgp->num_slices = 1;
 	msix_cap = pci_find_capability(pdev, PCI_CAP_ID_MSIX);
-	ncpus = num_online_cpus();
+	ncpus = min_t(int, num_online_cpus(), DEFAULT_MAX_NUM_RSS_QUEUES);
 
 	if (myri10ge_max_slices == 1 || msix_cap == 0 ||
 	    (myri10ge_max_slices == -1 && ncpus < 2))
-- 
1.7.9.rc2
