From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] e1000e: suggest a possible workaround to a device hang on 82577/8
Date: Thu,  3 May 2012 02:56:24 -0700
Message-ID: <1336038992-3144-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64596 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752196Ab2ECJ4e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 05:56:34 -0400
In-Reply-To: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

There is a known issue in the 82577 and 82578 device that can cause a hang
in the device hardware during traffic stress; the current workaround in the
driver is to disable transmit flow control by default.  If the user enables
transmit flow control and the device hang occurs, provide a message in the
syslog suggesting to re-enable the workaround.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index c0e211b..e86b524 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1084,6 +1084,10 @@ static void e1000_print_hw_hang(struct work_struct *work)
 	      phy_1000t_status,
 	      phy_ext_status,
 	      pci_status);
+
+	/* Suggest workaround for known h/w issue */
+	if ((hw->mac.type == e1000_pchlan) && (er32(CTRL) & E1000_CTRL_TFCE))
+		e_err("Try turning off Tx pause (flow control) via ethtool\n");
 }
 
 /**
-- 
1.7.7.6
