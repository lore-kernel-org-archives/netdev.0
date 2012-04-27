From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH BUG-FIX] igbvf: fix the bug when initializing the igbvf
Date: Fri, 27 Apr 2012 16:58:36 +0800
Message-ID: <4F9A5FBC.1060607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>
To: samuelliao@tencent.com,
	Jeffrey T Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	John Ronciak <john.ronciak@intel.com>,
	David Miller <davem@davemloft.net>, mitch.a.williams@intel.com,
	jpirko@redhat.com, danny.kukawka@bisect.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:42608 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832Ab2D0I5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 04:57:52 -0400
Received: by pbbrp8 with SMTP id rp8so311209pbb.19
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 01:57:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samuel Liao <samuelliao@tencent.com>


Maybe it's a typo, but it cause that igbvf can't be initialized successfully.
Set perm_addr value using valid dev_addr, although which is equal to hw.mac.addr.


Signed-off-by: Samuel Liao <samuelliao@tencent.com>
Signed-off-by: Shan Wei <davidshan@tencent.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index d61ca2a..8ec74b0 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2731,14 +2731,14 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 			netdev->addr_len);
 	}
 
-	if (!is_valid_ether_addr(netdev->perm_addr)) {
+	if (!is_valid_ether_addr(netdev->dev_addr)) {
 		dev_err(&pdev->dev, "Invalid MAC Address: %pM\n",
 		        netdev->dev_addr);
 		err = -EIO;
 		goto err_hw_init;
 	}
 
-	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
+	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
 
 	setup_timer(&adapter->watchdog_timer, &igbvf_watchdog,
 	            (unsigned long) adapter);
-- 
1.7.1
