From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 13/22] e1000: disable TSO when debugging slab
Date: Fri, 08 Dec 2006 15:03:13 -0800
Message-ID: <20061208230313.30109.28746.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4389 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761261AbWLHWxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:53:08 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


CONFIG_DEBUG_SLAB kills TSO on the 82544, so we're better off turing TSO
off in this rare case, assuming performance is not an issue for people
running slab debugging.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 9ddcadd..12f9f61 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -998,6 +998,12 @@ e1000_probe(struct pci_dev *pdev,
 	   (adapter->hw.mac_type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
 
+#ifdef CONFIG_DEBUG_SLAB
+	/* 82544's work arounds do not play nicely with DEBUG SLAB */
+	if (adapter->hw.mac_type == e1000_82544)
+		netdev->features &= ~NETIF_F_TSO;
+#endif
+
 #ifdef NETIF_F_TSO6
 	if (adapter->hw.mac_type > e1000_82547_rev_2)
 		netdev->features |= NETIF_F_TSO6;



---
Auke Kok <auke-jan.h.kok@intel.com>
