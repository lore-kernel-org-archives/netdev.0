From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] net: atm: make atmdev_ops const
Date: Wed,  9 Aug 2017 15:02:08 +0530
Message-ID: <1502271128-6832-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make these const as they are only stored in the ops field of a atm_dev
structure, which is const.
Done using Coccinelle.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 net/atm/clip.c      | 2 +-
 net/atm/lec.c       | 2 +-
 net/atm/mpc.c       | 2 +-
 net/atm/signaling.c | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index f271a7b..65f706e 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -617,7 +617,7 @@ static void atmarpd_close(struct atm_vcc *vcc)
 	module_put(THIS_MODULE);
 }
 
-static struct atmdev_ops atmarpd_dev_ops = {
+static const struct atmdev_ops atmarpd_dev_ops = {
 	.close = atmarpd_close
 };
 
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 093fe87..a3d93a1 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -486,7 +486,7 @@ static void lec_atm_close(struct atm_vcc *vcc)
 	module_put(THIS_MODULE);
 }
 
-static struct atmdev_ops lecdev_ops = {
+static const struct atmdev_ops lecdev_ops = {
 	.close = lec_atm_close,
 	.send = lec_atm_send
 };
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 680a4b9..5677147 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -779,7 +779,7 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 	netif_rx(new_skb);
 }
 
-static struct atmdev_ops mpc_ops = { /* only send is required */
+static const struct atmdev_ops mpc_ops = { /* only send is required */
 	.close	= mpoad_close,
 	.send	= msg_from_mpoad
 };
diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index 983c3a2..0a20f6e 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -217,7 +217,7 @@ static void sigd_close(struct atm_vcc *vcc)
 	read_unlock(&vcc_sklist_lock);
 }
 
-static struct atmdev_ops sigd_dev_ops = {
+static const struct atmdev_ops sigd_dev_ops = {
 	.close = sigd_close,
 	.send =	sigd_send
 };
-- 
1.9.1
