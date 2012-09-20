From: Ed Cashin <ecashin@coraid.com>
Subject: [PATCH 1/2] aoe: assert AoE packets marked as requiring no checksum
Date: Wed, 19 Sep 2012 18:46:39 -0700
Message-ID: <b4821fa88e0a0047eaa40011e8440e3d68575f75.1348105262.git.ecashin@coraid.com>
References: <cover.1348105262.git.ecashin@coraid.com>
Cc: ecashin@coraid.com, akpm@linux-foundation.org,
	bhutchings@solarflare.com, jesse@nicira.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1348105262.git.ecashin@coraid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order for the network layer to see that AoE requires
no checksumming in a generic way, the packets must be
marked as requiring no checksum, so we make this requirement
explicit with the assertion.

Signed-off-by: Ed Cashin <ecashin@coraid.com>
---
 drivers/block/aoe/aoecmd.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index de0435e..887f68f 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -35,6 +35,7 @@ new_skb(ulong len)
 		skb_reset_mac_header(skb);
 		skb_reset_network_header(skb);
 		skb->protocol = __constant_htons(ETH_P_AOE);
+		skb_checksum_none_assert(skb);
 	}
 	return skb;
 }
-- 
1.7.2.5
