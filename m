From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/5] igb: set num_rx/tx_queues to 0 when queues are freed
Date: Tue, 31 Mar 2009 23:38:19 -0700
Message-ID: <20090401063819.3046.60000.stgit@lost.foo-projects.org>
References: <20090401063759.3046.89960.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:54128
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756801AbZDAGij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 02:38:39 -0400
In-Reply-To: <20090401063759.3046.89960.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

An issue was seen on suspend in which the system reported a page fault.  This
was due to the new reg_idx code being called after the queues were freed.

This update prevents any for loops from going through the queues by setting
the number of queues to 0 when they are freed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index be02045..10b095d 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -420,6 +420,9 @@ static void igb_free_queues(struct igb_adapter *adapter)
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		netif_napi_del(&adapter->rx_ring[i].napi);
 
+	adapter->num_rx_queues = 0;
+	adapter->num_tx_queues = 0;
+
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 }

