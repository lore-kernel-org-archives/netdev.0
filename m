From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: Drop WARN() in tag_brcm.c
Date: Mon, 23 Jan 2017 19:19:07 -0800
Message-ID: <20170124031907.28328-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We may be able to see invalid Broadcom tags when the hardware and drivers are
misconfigured, or just while exercising the error path. Instead of flooding
the console with messages, flat out drop the packet.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/tag_brcm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index af82927674e0..cb5a2b7a0118 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -121,7 +121,8 @@ static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	/* We should never see a reserved reason code without knowing how to
 	 * handle it
 	 */
-	WARN_ON(brcm_tag[2] & BRCM_EG_RC_RSVD);
+	if (unlikely(brcm_tag[2] & BRCM_EG_RC_RSVD))
+		goto out_drop;
 
 	/* Locate which port this is coming from */
 	source_port = brcm_tag[3] & BRCM_EG_PID_MASK;
-- 
2.9.3
