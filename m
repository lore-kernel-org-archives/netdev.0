From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] e1000e/ethtool.c: fix error checks
Date: Sun, 14 Oct 2007 19:51:04 +0200
Message-ID: <20071014175104.GK4211@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>, Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761496AbXJNRvh@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You want to check for the value, not for the address.

Spotted by the Coverity checker.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1451,11 +1451,11 @@ static int e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 	}
 
 	*data = e1000_setup_desc_rings(adapter);
-	if (data)
+	if (*data)
 		goto out;
 
 	*data = e1000_setup_loopback_test(adapter);
-	if (data)
+	if (*data)
 		goto err_loopback;
 
 	*data = e1000_run_loopback_test(adapter);
