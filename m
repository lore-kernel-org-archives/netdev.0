From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/3] ixgbe: skip non IPv4 packets in ATR filter
Date: Tue, 29 Jun 2010 21:29:00 -0700
Message-ID: <20100630042859.8925.23844.stgit@localhost.localdomain>
References: <20100630042739.8925.24962.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Guillaume Gaudonville <guillaume.gaudonville@6wind.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:46795
	"EHLO qmta14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751115Ab0F3E3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 00:29:24 -0400
In-Reply-To: <20100630042739.8925.24962.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Gaudonville <guillaume.gaudonville@6wind.com>

In driver ixgbe, ixgbe_atr may cause crashes for non-ipv4 packets. Just
add a test to check skb->protocol.  It may crash on short packets due
to ip_hdr() access.

Signed-off-by: Guillaume Gaudonville <guillaume.gaudonville@6wind.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7ddd60e..a0b3316 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6024,7 +6024,6 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
 	              int queue, u32 tx_flags)
 {
-	/* Right now, we support IPv4 only */
 	struct ixgbe_atr_input atr_input;
 	struct tcphdr *th;
 	struct iphdr *iph = ip_hdr(skb);
@@ -6033,6 +6032,9 @@ static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
 	u32 src_ipv4_addr, dst_ipv4_addr;
 	u8 l4type = 0;
 
+	/* Right now, we support IPv4 only */
+	if (skb->protocol != htons(ETH_P_IP))
+		return;
 	/* check if we're UDP or TCP */
 	if (iph->protocol == IPPROTO_TCP) {
 		th = tcp_hdr(skb);

