From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH 3/9] net: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL) in drivers/net/macvtap.c
Date: Thu, 20 Mar 2014 20:10:49 +0530
Message-ID: <a526cbfdba8a9a3380b685d34b4ee7ce52163d57.1395324808.git.monamagarwal123@gmail.com>
References: <23ae65fa8bad7f9092739a52e35fdf9d4e8576a3.1395324808.git.monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <23ae65fa8bad7f9092739a52e35fdf9d4e8576a3.1395324808.git.monamagarwal123@gmail.com>
In-Reply-To: <cover.1395324808.git.monamagarwal123@gmail.com>
References: <cover.1395324808.git.monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 drivers/net/macvtap.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 1b7082d..7c88d13 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -145,8 +145,8 @@ static void macvtap_put_queue(struct macvtap_queue *q)
 	if (vlan) {
 		int index = get_slot(vlan, q);
 
-		rcu_assign_pointer(vlan->taps[index], NULL);
-		rcu_assign_pointer(q->vlan, NULL);
+		RCU_INIT_POINTER(vlan->taps[index], NULL);
+		RCU_INIT_POINTER(q->vlan, NULL);
 		sock_put(&q->sk);
 		--vlan->numvtaps;
 	}
@@ -223,8 +223,8 @@ static void macvtap_del_queues(struct net_device *dev)
 					      lockdep_is_held(&macvtap_lock));
 		if (q) {
 			qlist[j++] = q;
-			rcu_assign_pointer(vlan->taps[i], NULL);
-			rcu_assign_pointer(q->vlan, NULL);
+			RCU_INIT_POINTER(vlan->taps[i], NULL);
+			RCU_INIT_POINTER(q->vlan, NULL);
 			vlan->numvtaps--;
 		}
 	}
-- 
1.7.9.5
