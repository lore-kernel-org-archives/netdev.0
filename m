From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: [PATCH] irda: use msecs_to_jiffies for conversions
Date: Thu, 29 Jan 2015 18:22:51 +0100
Message-ID: <1422552171-25947-1-git-send-email-der.herr@hofr.at>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <der.herr@hofr.at>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is only an API consolidation and should make things more readable
it replaces  var * HZ / 1000  constructs by  msecs_to_jiffies(var).

Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
---

Converting milliseconds to jiffies by val * HZ / 1000 is technically
not wrong but msecs_to_jiffies(val) is the cleaner solution and handles
all corner cases correctly. This is a minor API cleanup only.

This patch was only compile tested with x86_64_defconfig +
CONFIG_IRDA=m

Patch is against 3.19.0-rc6 -next-20150129

 net/irda/irlap.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/irda/irlap.c b/net/irda/irlap.c
index 7f2cafd..1cde711 100644
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -533,7 +533,7 @@ void irlap_discovery_request(struct irlap_cb *self, discovery_t *discovery)
 	info.discovery = discovery;
 
 	/* sysctl_slot_timeout bounds are checked in irsysctl.c - Jean II */
-	self->slot_timeout = sysctl_slot_timeout * HZ / 1000;
+	self->slot_timeout = msecs_to_jiffies(sysctl_slot_timeout);
 
 	irlap_do_event(self, DISCOVERY_REQUEST, NULL, &info);
 }
@@ -1015,13 +1015,15 @@ void irlap_apply_connection_parameters(struct irlap_cb *self, int now)
 	 * Or, this is how much we can keep the pf bit in primary mode.
 	 * Therefore, it must be lower or equal than our *OWN* max turn around.
 	 * Jean II */
-	self->poll_timeout = self->qos_tx.max_turn_time.value * HZ / 1000;
+	self->poll_timeout = msecs_to_jiffies(
+				self->qos_tx.max_turn_time.value);
 	/* The Final timeout applies only to the primary station.
 	 * It defines the maximum time the primary wait (mostly in RECV mode)
 	 * for an answer from the secondary station before polling it again.
 	 * Therefore, it must be greater or equal than our *PARTNER*
 	 * max turn around time - Jean II */
-	self->final_timeout = self->qos_rx.max_turn_time.value * HZ / 1000;
+	self->final_timeout = msecs_to_jiffies(
+				self->qos_rx.max_turn_time.value);
 	/* The Watchdog Bit timeout applies only to the secondary station.
 	 * It defines the maximum time the secondary wait (mostly in RECV mode)
 	 * for poll from the primary station before getting annoyed.
-- 
1.7.10.4
