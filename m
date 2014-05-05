From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 23/24] net, diet: Add coccinelle script to convert drivers to ETHTOOL_OPS
Date: Mon,  5 May 2014 15:26:12 -0700
Message-ID: <1399328773-6531-24-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>,
	Julia Lawall <Julia.Lawall@lip6.fr>,
	Gilles Muller <Gilles.Muller@lip6.fr>,
	Nicolas Palix <nicolas.palix@imag.fr>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

Useful to remove unneeded driver code when ethtool is disabled.

The patches doing this are submitted too, but let's add
the script too so people can re-use it.

Cc: Julia Lawall <Julia.Lawall@lip6.fr>
Cc: Gilles Muller <Gilles.Muller@lip6.fr>
Cc: Nicolas Palix <nicolas.palix@imag.fr>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 scripts/coccinelle/api/ethtool_ops.cocci | 9 +++++++++
 1 file changed, 9 insertions(+)
 create mode 100644 scripts/coccinelle/api/ethtool_ops.cocci

diff --git a/scripts/coccinelle/api/ethtool_ops.cocci b/scripts/coccinelle/api/ethtool_ops.cocci
new file mode 100644
index 0000000..a7ee6ed
--- /dev/null
+++ b/scripts/coccinelle/api/ethtool_ops.cocci
@@ -0,0 +1,9 @@
+// Convert network drivers to use the SET_ETHTOOL_OPS macro
+// This allows to compile out the ethtool code when not needed.
+//
+@@
+struct ethtool_ops *ops;
+struct net_device *dev;
+@@
+-	dev->ethtool_ops = ops;
++	SET_ETHTOOL_OPS(dev, ops);
-- 
1.9.0
