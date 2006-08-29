From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 02/26] e1000: IRQ resources cleanup
Date: Tue, 29 Aug 2006 09:44:18 -0700
Message-ID: <20060829164418.6872.33175.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:26122 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965074AbWH2QgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:05 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


irq leak was found in 2.6.18-rc4 and e1000 7.2.7 from sourceforge: if
e1000_up fails in e1000_open() we do not free allocated irq

Signed-off-by: Vasily Averin <vvs@sw.ru>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 610a0cd..354d778 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1207,7 +1207,7 @@ e1000_open(struct net_device *netdev)
 
 	err = e1000_request_irq(adapter);
 	if (err)
-		goto err_up;
+		goto err_req_irq;
 
 	e1000_power_up_phy(adapter);
 
@@ -1228,6 +1228,9 @@ e1000_open(struct net_device *netdev)
 	return E1000_SUCCESS;
 
 err_up:
+	e1000_power_down_phy(adapter);
+	e1000_free_irq(adapter);
+err_req_irq:
 	e1000_free_all_rx_resources(adapter);
 err_setup_rx:
 	e1000_free_all_tx_resources(adapter);



---
Auke Kok <auke-jan.h.kok@intel.com>
