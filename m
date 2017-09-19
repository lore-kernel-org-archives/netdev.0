From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/4] net: dsa: setup master ethtool unconditionally
Date: Tue, 19 Sep 2017 11:56:58 -0400
Message-ID: <20170919155700.14474-3-vivien.didelot@savoirfairelinux.com>
References: <20170919155700.14474-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919155700.14474-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a DSA switch tree is meant to be applied, it already has a CPU
port. Thus remove the condition of dst->cpu_dp.

Moreover, the next lines access dst->cpu_dp unconditionally.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa2.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 873af0108e24..bd19304f862f 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -433,11 +433,9 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 			return err;
 	}
 
-	if (dst->cpu_dp) {
-		err = dsa_cpu_port_ethtool_setup(dst->cpu_dp);
-		if (err)
-			return err;
-	}
+	err = dsa_cpu_port_ethtool_setup(dst->cpu_dp);
+	if (err)
+		return err;
 
 	/* If we use a tagging format that doesn't have an ethertype
 	 * field, make sure that all packets from this point on get
@@ -474,10 +472,8 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 		dsa_ds_unapply(dst, ds);
 	}
 
-	if (dst->cpu_dp) {
-		dsa_cpu_port_ethtool_restore(dst->cpu_dp);
-		dst->cpu_dp = NULL;
-	}
+	dsa_cpu_port_ethtool_restore(dst->cpu_dp);
+	dst->cpu_dp = NULL;
 
 	pr_info("DSA: tree %d unapplied\n", dst->tree);
 	dst->applied = false;
-- 
2.14.1
