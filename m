From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/7] e1000e: Enclose e1000e_pm_thaw() with CONFIG_PM_SLEEP
Date: Fri, 18 Apr 2014 18:59:24 -0700
Message-ID: <1397872767-4001-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1397872767-4001-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2813 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753950AbaDSB7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2014 21:59:32 -0400
In-Reply-To: <1397872767-4001-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

=46ix following compilation warning:
drivers/net/ethernet/intel/e1000e/netdev.c:6238:12: warning
=E2=80=98e1000e_pm_thaw=E2=80=99 defined but not used [-Wunused-functio=
n]
 static int e1000e_pm_thaw(struct device *dev)
            ^
Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/e=
thernet/intel/e1000e/netdev.c
index 165f7bc..8926a13 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6235,6 +6235,7 @@ static int __e1000_resume(struct pci_dev *pdev)
 	return 0;
 }
=20
+#ifdef CONFIG_PM_SLEEP
 static int e1000e_pm_thaw(struct device *dev)
 {
 	struct net_device *netdev =3D pci_get_drvdata(to_pci_dev(dev));
@@ -6255,7 +6256,6 @@ static int e1000e_pm_thaw(struct device *dev)
 	return 0;
 }
=20
-#ifdef CONFIG_PM_SLEEP
 static int e1000e_pm_suspend(struct device *dev)
 {
 	struct pci_dev *pdev =3D to_pci_dev(dev);
--=20
1.9.0
