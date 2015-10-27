From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH 3/6] net: dsa: cleanup resources upon module removal
Date: Tue, 27 Oct 2015 15:49:03 +0100
Message-ID: <562F8EDF.9080604@baylibre.com>
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
processing go through the regular Ethernet receive path.

Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 7c9914b..acbf854 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -951,6 +951,14 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
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
