From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 7/8] r8169: (re)init phy on resume
Date: Thu, 21 Oct 2010 10:25:42 +0200
Message-ID: <1287649543-6569-8-git-send-email-sgruszka@redhat.com>
References: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753537Ab0JUIXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 04:23:35 -0400
In-Reply-To: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix switching device to low-speed mode after resume reported in:
https://bugzilla.redhat.com/show_bug.cgi?id=502974

Reported-and-tested-by: Laurentiu Badea <bugzilla-redhat@wotevah.com>
Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/r8169.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index ad3f37a..1165e7d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4824,6 +4824,9 @@ static int rtl8169_resume(struct device *device)
 {
 	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *dev = pci_get_drvdata(pdev);
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	rtl8169_init_phy(dev, tp);
 
 	if (netif_running(dev))
 		__rtl8169_resume(dev);
@@ -4864,6 +4867,8 @@ static int rtl8169_runtime_resume(struct device *device)
 	tp->saved_wolopts = 0;
 	spin_unlock_irq(&tp->lock);
 
+	rtl8169_init_phy(dev, tp);
+
 	__rtl8169_resume(dev);
 
 	return 0;
-- 
1.6.5.2

