From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH v2 2/2] vlan: updates vlan real_num_tx_queues
Date: Tue, 23 Mar 2010 17:42:05 -0700
Message-ID: <20100324004204.31609.55285.stgit@localhost.localdomain>
References: <20100324004116.31609.73183.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Vasu Dev <vasu.dev@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:39317
	"EHLO qmta04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753560Ab0CXAmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 20:42:24 -0400
In-Reply-To: <20100324004116.31609.73183.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

Updates real_num_tx_queues in case underlying real device
has changed real_num_tx_queues.

-v2
 As per Eric Dumazet<eric.dumazet@gmail.com> comment:-
   -- adds BUG_ON to catch case of real_num_tx_queues exceeding num_tx_queues.
   -- created this self contained patch to just update real_num_tx_queues.

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/8021q/vlan.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 4535122..db783d7 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -378,6 +378,8 @@ static void vlan_transfer_features(struct net_device *dev,
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	vlandev->fcoe_ddp_xid = dev->fcoe_ddp_xid;
 #endif
+	vlandev->real_num_tx_queues = dev->real_num_tx_queues;
+	BUG_ON(vlandev->real_num_tx_queues > vlandev->num_tx_queues);
 
 	if (old_features != vlandev->features)
 		netdev_features_change(vlandev);

