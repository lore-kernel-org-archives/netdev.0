From: Amit Choudhary <amit2030@gmail.com>
Subject: [PATCH] [REVISED] net/ipv4/multipath_wrandom.c: check kmalloc()
 return value.
Date: Thu, 8 Mar 2007 23:22:15 -0800
Message-ID: <20070308232215.aa512aaa.amit2030@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Linux Kernel <linux-kernel@vger.kernel.org>, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S2993050AbXCIHWj@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Description: Check the return value of kmalloc() in function wrandom_set_nhinfo(), in file net/ipv4/multipath_wrandom.c.

Signed-off-by: Amit Choudhary <amit2030@gmail.com>

diff --git a/net/ipv4/multipath_wrandom.c b/net/ipv4/multipath_wrandom.c
index 92b0482..bcdb1f1 100644
--- a/net/ipv4/multipath_wrandom.c
+++ b/net/ipv4/multipath_wrandom.c
@@ -242,6 +242,9 @@ static void wrandom_set_nhinfo(__be32 ne
 		target_route = (struct multipath_route *)
 			kmalloc(size_rt, GFP_ATOMIC);
 
+		if (!target_route)
+			goto error;
+
 		target_route->gw = nh->nh_gw;
 		target_route->oif = nh->nh_oif;
 		memset(&target_route->rcu, 0, sizeof(struct rcu_head));
@@ -263,6 +266,9 @@ static void wrandom_set_nhinfo(__be32 ne
 		target_dest = (struct multipath_dest*)
 			kmalloc(size_dst, GFP_ATOMIC);
 
+		if (!target_dest)
+			goto error;
+
 		target_dest->nh_info = nh;
 		target_dest->network = network;
 		target_dest->netmask = netmask;
@@ -275,6 +281,7 @@ static void wrandom_set_nhinfo(__be32 ne
 	 * we are finished
 	 */
 
+ error:
 	spin_unlock_bh(&state[state_idx].lock);
 }
 
