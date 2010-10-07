From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH v2] net: netif_set_real_num_rx_queues may cap
	num_rx_queues at init time
Date: Wed, 06 Oct 2010 17:05:55 -0700
Message-ID: <20101007000501.25653.55904.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:60707
	"EHLO qmta09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758167Ab0JGAGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 20:06:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Do not set num_rx_queues in netif_set_real_num_rx_queues() some
drivers will increase the real_num_rx_queues later due to a feature
changes or available interrupts increasing. By setting num_rx_queues
here this ends up creating a cap on the number of rx queues
available.

For example the ixgbe driver sets the max number of queues it intends
to use ever then sets the current number in use with the
netif_set_num_{rx|tx}_queues calls. With the current implementation
the number of rx queues gets limited so when a feature such as DCB
or FCoE is enabled the queues are no longer available.

kobjects will only be allocated for real_num_rx_queues so the waste
in memory is minimal.

CC: Ben Hutchings <bhutchings@solarflare.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/core/dev.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7d14955..fd1b75a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1593,8 +1593,6 @@ int netif_set_real_num_rx_queues(struct net_device *dev, unsigned int rxq)
 						  rxq);
 		if (rc)
 			return rc;
-	} else {
-		dev->num_rx_queues = rxq;
 	}
 
 	dev->real_num_rx_queues = rxq;

