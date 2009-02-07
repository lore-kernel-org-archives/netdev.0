From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 23/26] igb: update stats before doing reset in
	igb_down
Date: Sat, 07 Feb 2009 01:22:32 -0800
Message-ID: <20090207092232.15697.12038.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:51139
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752574AbZBGJWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:22:52 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

It was seen with repeated interface up/down testing that there was a large
stray between the stats reported by the queues and the stats reported by the
HW.  It was found to be an issue in that hw stats were being reset without
first being recorded.  This change records the stats before wiping them from
the system via the reset.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 3b79ad8..88f135f 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -858,6 +858,10 @@ void igb_down(struct igb_adapter *adapter)
 
 	netdev->tx_queue_len = adapter->tx_queue_len;
 	netif_carrier_off(netdev);
+
+	/* record the stats before reset*/
+	igb_update_stats(adapter);
+
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 

