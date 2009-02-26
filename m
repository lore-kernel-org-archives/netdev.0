From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH] igb: remove skb_orphan calls
Date: Thu, 26 Feb 2009 02:46:23 -0800
Message-ID: <20090226104621.10407.46879.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:34135
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755926AbZBZKqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 05:46:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The skb_orphan call in the tx path has been shown to cause issues as seen
with the workarounds required for timestamping.

In order to avoid this it is easiest just to remove the skb_orphan call as
the motivation for including it was purely performance based, and the
overall gain from having the call was minimal.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 6cae258..78558f8 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3258,14 +3258,6 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	if (unlikely(shtx->hardware)) {
 		shtx->in_progress = 1;
 		tx_flags |= IGB_TX_FLAGS_TSTAMP;
-	} else if (likely(!shtx->software)) {
-		/*
-		 * TODO: can this be solved in dev.c:dev_hard_start_xmit()?
-		 * There are probably unmodified driver which do something
-		 * like this and thus don't work in combination with
-		 * SOF_TIMESTAMPING_TX_SOFTWARE.
-		 */
-		skb_orphan(skb);
 	}
 
 	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
@@ -4253,9 +4245,6 @@ static void igb_tx_hwtstamp(struct igb_adapter *adapter, struct sk_buff *skb)
 				timecompare_transform(&adapter->compare, ns);
 			skb_tstamp_tx(skb, &shhwtstamps);
 		}
-
-		/* delayed orphaning: skb_tstamp_tx() needs the socket */
-		skb_orphan(skb);
 	}
 }
 

