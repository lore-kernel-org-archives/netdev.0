From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 5/6] e1000e: flow control thresholds not correct when
	changing mtu
Date: Thu, 19 Nov 2009 14:35:45 -0800
Message-ID: <20091119223545.29164.67210.stgit@localhost.localdomain>
References: <20091119223406.29164.22513.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:56098
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756296AbZKSWf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 17:35:57 -0500
In-Reply-To: <20091119223406.29164.22513.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When changing MTU, save it off prior to resetting otherwise the flow control
thresholds may be miscalculated.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 6345827..fad8f9e 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4305,8 +4305,10 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
 		msleep(1);
-	/* e1000e_down has a dependency on max_frame_size */
+	/* e1000e_down -> e1000e_reset dependent on max_frame_size & mtu */
 	adapter->max_frame_size = max_frame;
+	e_info("changing MTU from %d to %d\n", netdev->mtu, new_mtu);
+	netdev->mtu = new_mtu;
 	if (netif_running(netdev))
 		e1000e_down(adapter);
 
@@ -4336,9 +4338,6 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		adapter->rx_buffer_len = ETH_FRAME_LEN + VLAN_HLEN
 					 + ETH_FCS_LEN;
 
-	e_info("changing MTU from %d to %d\n", netdev->mtu, new_mtu);
-	netdev->mtu = new_mtu;
-
 	if (netif_running(netdev))
 		e1000e_up(adapter);
 	else

