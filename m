From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 5/5] ixgbe: Remove ATR computation for UDP traffic
Date: Wed, 30 Sep 2009 15:08:37 -0700
Message-ID: <20090930220836.27479.74285.stgit@localhost.localdomain>
References: <20090930220705.27479.62694.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:38946
	"EHLO QMTA12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753827AbZI3WJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 18:09:38 -0400
In-Reply-To: <20090930220705.27479.62694.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

ATR support for UDP on 82599 needs to be redesigned, since the
current model doesn't make much sense.  The fallout from having
it in though is it causes all UDP traffic to still compute the
ATR hashes on transmit, which are useless.  This removal will
return upwards of 10% of relative computational overhead in
forwarding tests.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 9609673..1cbc6a3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5091,7 +5091,6 @@ static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
 	/* Right now, we support IPv4 only */
 	struct ixgbe_atr_input atr_input;
 	struct tcphdr *th;
-	struct udphdr *uh;
 	struct iphdr *iph = ip_hdr(skb);
 	struct ethhdr *eth = (struct ethhdr *)skb->data;
 	u16 vlan_id, src_port, dst_port, flex_bytes;
@@ -5105,12 +5104,6 @@ static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
 		dst_port = th->dest;
 		l4type |= IXGBE_ATR_L4TYPE_TCP;
 		/* l4type IPv4 type is 0, no need to assign */
-	} else if(iph->protocol == IPPROTO_UDP) {
-		uh = udp_hdr(skb);
-		src_port = uh->source;
-		dst_port = uh->dest;
-		l4type |= IXGBE_ATR_L4TYPE_UDP;
-		/* l4type IPv4 type is 0, no need to assign */
 	} else {
 		/* Unsupported L4 header, just bail here */
 		return;

