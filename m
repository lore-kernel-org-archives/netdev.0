From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 14/14] r8169: add shutdown handler
Date: Fri, 10 Oct 2008 23:48:54 +0200
Message-ID: <20081010214854.GN27195@electric-eye.fr.zoreil.com>
References: <20081006071229.GA23039@electric-eye.fr.zoreil.com> <20081007222202.GA9393@electric-eye.fr.zoreil.com> <20081009190015.GB19721@electric-eye.fr.zoreil.com> <20081009.122026.239988133.davem@davemloft.net> <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamagallon@ono.com, greg@kroah.com, netdev@vger.kernel.org,
	bonbons@linux-vserver.org, ivecera@redhat.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	ishikawa <chiaki.ishikawa@ubin.jp>, Mark Lord <lkml@rtr.ca>,
	edward_hsu@realtek.com.tw
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34049 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764811AbYJJVuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 17:50:25 -0400
Content-Disposition: inline
In-Reply-To: <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 02b11a0..bdae2c5 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3874,6 +3874,11 @@ out:
 	return 0;
 }
 
+static void rtl_shutdown(struct pci_dev *pdev)
+{
+	rtl8169_suspend(pdev, PMSG_SUSPEND);
+}
+
 #endif /* CONFIG_PM */
 
 static struct pci_driver rtl8169_pci_driver = {
@@ -3884,6 +3889,7 @@ static struct pci_driver rtl8169_pci_driver = {
 #ifdef CONFIG_PM
 	.suspend	= rtl8169_suspend,
 	.resume		= rtl8169_resume,
+	.shutdown	= rtl_shutdown,
 #endif
 };
 
-- 
1.5.3.3

