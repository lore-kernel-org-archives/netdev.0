From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 06/14] r8169: 8168b Tx performance tweak
Date: Fri, 10 Oct 2008 23:42:34 +0200
Message-ID: <20081010214234.GF27195@electric-eye.fr.zoreil.com>
References: <20081006071229.GA23039@electric-eye.fr.zoreil.com> <20081007222202.GA9393@electric-eye.fr.zoreil.com> <20081009190015.GB19721@electric-eye.fr.zoreil.com> <20081009.122026.239988133.davem@davemloft.net> <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamagallon@ono.com, greg@kroah.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bonbons@linux-vserver.org,
	ivecera@redhat.com, Ben Hutchings <bhutchings@solarflare.com>,
	ishikawa <chiaki.ishikawa@ubin.jp>, Mark Lord <lkml@rtr.ca>,
	edward_hsu@realtek.com.tw
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37906 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759878AbYJJVnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 17:43:09 -0400
Content-Disposition: inline
In-Reply-To: <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 60d2ded..f929dba 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2386,7 +2386,8 @@ static void rtl_ephy_init(void __iomem *ioaddr, struct ephy_info *e, int len)
 
 static void rtl_hw_start_8168bb(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	rtl_tx_performance_tweak(pdev,
+		(0x5 << MAX_READ_REQUEST_SHIFT) | PCI_EXP_DEVCTL_NOSNOOP_EN);
 }
 
 static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
-- 
1.5.3.3

