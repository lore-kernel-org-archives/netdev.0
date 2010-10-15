From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: DCB: remove DCB check config
Date: Thu, 14 Oct 2010 22:21:22 -0700
Message-ID: <20101015051846.32242.1734.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:36686
	"EHLO qmta13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753232Ab0JOFVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 01:21:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Remove a DCB check config from DCB configuration we
continue to configure DCB even if it fails so don't
even bother to check.  Plus user space (lldpad) checks
this before programming the hw anyways.

Worse case is we program some values into the hw that
don't make total sense resulting in incorrect bandwidth
allocation.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 95dbf60..790a0da 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3374,7 +3374,6 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		netif_set_gso_max_size(adapter->netdev, 32768);
 
-	ixgbe_dcb_check_config(&adapter->dcb_cfg);
 	ixgbe_dcb_calculate_tc_credits(&adapter->dcb_cfg, DCB_TX_CONFIG);
 	ixgbe_dcb_calculate_tc_credits(&adapter->dcb_cfg, DCB_RX_CONFIG);
 

