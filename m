From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH]: e1000: error out if we cannot enable PCI device on resume
Date: Mon, 21 Aug 2006 14:33:34 -0700
Message-ID: <44EA26AE.4020304@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000402020403090802020907"
Cc: NetDev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>, vvs@sw.ru,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4918 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751163AbWHUVfT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 17:35:19 -0400
To: Andrew Morton <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000402020403090802020907
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


FYI, in light of the recent error handling patches. I'll stack the outstanding 
list submitted by Vasily Averin to our git repository for submission to #upstream.

Cheers,

Auke

---

  e1000_main.c |    7 +++++--
  1 file changed, 5 insertions(+), 2 deletions(-)
---


--------------000402020403090802020907
Content-Type: text/x-patch;
 name="e1000_trap_error_on_resume.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="e1000_trap_error_on_resume.patch"


e1000: error out if we cannot enable PCI device on resume

Do not ignore errors returned by pci_enable_device, instead error out.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 815abe5..7805d7f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4695,11 +4695,14 @@ e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t manc, ret_val;
+	uint32_t manc, err;
 
 	pci_set_power_state(pdev, PCI_D0);
 	e1000_pci_restore_state(adapter);
-	ret_val = pci_enable_device(pdev);
+	if ((err = pci_enable_device(pdev))) {
+		printk(KERN_ERR "e1000: Cannot enable PCI device from suspend\n");
+		return err;
+	}
 	pci_set_master(pdev);
 
 	pci_enable_wake(pdev, PCI_D3hot, 0);

--------------000402020403090802020907--
