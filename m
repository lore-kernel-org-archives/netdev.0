From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 03/23] e1000e: clearing interrupt timers causes
	descriptors to get flushed
Date: Sat, 21 Nov 2009 01:22:39 -0800
Message-ID: <20091121092238.5715.9091.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:37074 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751831AbZKUJWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:22:49 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Clearing the interrupt timers following an IMS clear has the unwanted
side-effect of flushing all descriptors immediately following a partial
write when interrupts are disabled.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3caa1d5..3845fb6 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2441,8 +2441,6 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 		ew32(ITR, 1000000000 / (adapter->itr * 256));
 
 	ctrl_ext = er32(CTRL_EXT);
-	/* Reset delay timers after every interrupt */
-	ctrl_ext |= E1000_CTRL_EXT_INT_TIMER_CLR;
 	/* Auto-Mask interrupts upon ICR access */
 	ctrl_ext |= E1000_CTRL_EXT_IAME;
 	ew32(IAM, 0xffffffff);

