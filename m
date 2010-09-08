From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/4] ixgbe: fix TX ring enable issues seen when
	VMDQ is enabled
Date: Wed, 08 Sep 2010 00:34:29 -0700
Message-ID: <20100908073229.722.61015.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.westchester.pa.mail.comcast.net ([76.96.59.228]:47960
	"EHLO qmta15.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758215Ab0IHHeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 03:34:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The ordering of operations was messed up in the init and as a result when
VMDQ was enabled we were trying to enable TX rings before setting the VFTE
bits. This resulted in a ring that appeared to fail to enable when in fact
it was blocked because the VFTE bits were cleared after the reset.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 3aafe94..0027d75 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3004,7 +3004,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 
 	/* Program registers for the distribution of queues */
 	ixgbe_setup_mrqc(adapter);
-	ixgbe_configure_virtualization(adapter);
 
 	ixgbe_set_uta(adapter);
 
@@ -3391,6 +3390,7 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 	} else if (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE) {
 		ixgbe_init_fdir_perfect_82599(hw, adapter->fdir_pballoc);
 	}
+	ixgbe_configure_virtualization(adapter);
 
 	ixgbe_configure_tx(adapter);
 	ixgbe_configure_rx(adapter);

