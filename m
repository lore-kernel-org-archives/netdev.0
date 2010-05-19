From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 6/7] ixgbe: dcb, do not tag tc_prio_control frames
Date: Tue, 18 May 2010 19:00:11 -0700
Message-ID: <20100519020011.18654.3836.stgit@localhost.localdomain>
References: <20100519020003.18654.94899.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:46158 "EHLO
	qmta09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753032Ab0ESCAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 22:00:12 -0400
In-Reply-To: <20100519020003.18654.94899.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The network stack indicate packets should not be DCB
tagged by setting the priority to TC_PRIO_CONTROL. One
usage for this is lldp frames which are not suppossed
to be tagged.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d80bb1a..caf1114 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6075,7 +6075,8 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 		}
 		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
-	} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+	} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED &&
+		   skb->priority != TC_PRIO_CONTROL) {
 		tx_flags |= ((skb->queue_mapping & 0x7) << 13);
 		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;

