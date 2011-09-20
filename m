From: Kasper Pedersen <kernel@kasperkp.dk>
Subject: [PATCH v2] tg3: fix VLAN tagging regression
Date: Wed, 21 Sep 2011 00:41:17 +0200
Message-ID: <4E79168D.4080201@kasperkp.dk>
References: <4E78FC38.7040903@kasperkp.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E78FC38.7040903@kasperkp.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 92cd3a17ce9c719abb4c28dee3438e0c641f8de4
    tg3: Simplify tx bd assignments

broke VLAN tagging on outbound packets.
It ifdef'ed BCM_KERNEL_SUPPORTS_8021Q, but this
is not set anywhere. So vlan never gets set, and
all packets are sent with vlan=0.

v2: We can just remove the test. vlan_tx_tag_present
is valid regardless of whether the 802.1q module
is built.

Tested on BCM5721 rev 11.

Signed-off-by: Kasper Pedersen <kernel@kasperkp.dk>
---
 drivers/net/tg3.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index dc3fbf6..4a1374d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6234,12 +6234,10 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-#ifdef BCM_KERNEL_SUPPORTS_8021Q
 	if (vlan_tx_tag_present(skb)) {
 		base_flags |= TXD_FLAG_VLAN;
 		vlan = vlan_tx_tag_get(skb);
 	}
-#endif
 
 	if (tg3_flag(tp, USE_JUMBO_BDFLAG) &&
 	    !mss && skb->len > VLAN_ETH_FRAME_LEN)
