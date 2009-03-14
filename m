From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/8] igb: remove netif running call from igb_poll
Date: Fri, 13 Mar 2009 23:40:38 -0700
Message-ID: <20090314064038.4052.2038.stgit@lost.foo-projects.org>
References: <20090314064020.4052.46249.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:36493 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751312AbZCNGk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 02:40:58 -0400
In-Reply-To: <20090314064020.4052.46249.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The netif_running check in igb poll is a hold over from the use of fake
netdevs to use multiple queues with NAPI prior to 2.6.24.  It is no longer
necessary to have the call there and it currently can cause errors if
work_done == budget.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 230898f..28b22c3 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4165,7 +4165,6 @@ static int igb_poll(struct napi_struct *napi, int budget)
 {
 	struct igb_ring *rx_ring = container_of(napi, struct igb_ring, napi);
 	struct igb_adapter *adapter = rx_ring->adapter;
-	struct net_device *netdev = adapter->netdev;
 	int work_done = 0;
 
 #ifdef CONFIG_IGB_DCA
@@ -4184,7 +4183,7 @@ static int igb_poll(struct napi_struct *napi, int budget)
 	}
 
 	/* If not enough Rx work done, exit the polling mode */
-	if ((work_done < budget) || !netif_running(netdev)) {
+	if (work_done < budget) {
 		napi_complete(napi);
 		igb_rx_irq_enable(rx_ring);
 	}

