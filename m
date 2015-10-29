From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v2 3/6] net: dsa: cleanup resources upon module removal
Date: Thu, 29 Oct 2015 14:23:12 +0100
Message-ID: <56321DC0.7010805@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure that we unassign the master_netdev dsa_ptr to make the packet
processing go through the regulard Ethernet receive path.

Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 19cff8f..b2f696c 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -949,6 +949,14 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 		flush_delayed_work(&dst->link_poll_work);
 	}

+	dst->master_netdev->dsa_ptr = NULL;
+
+	/* If we used a tagging format that doesn't have an ethertype
+	 * field, make sure that all packets from this point get sent
+	 * without the tag and go through the regular receive path.
+	 */
+	wmb();
+
 	for (i = 0; i < dst->pd->nr_chips; i++) {
 		struct dsa_switch *ds = dst->ds[i];

-- 
1.9.1
