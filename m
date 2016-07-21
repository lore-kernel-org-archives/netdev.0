From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: bridge: br_set_ageing_time takes a clock_t
Date: Thu, 21 Jul 2016 12:42:19 -0400
Message-ID: <20160721164219.26723-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the ageing_time type in br_set_ageing_time() from u32 to what it
is expected to be, i.e. a clock_t.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_private.h | 2 +-
 net/bridge/br_stp.c     | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 52edecf..b12447e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -942,7 +942,7 @@ void __br_set_forward_delay(struct net_bridge *br, unsigned long t);
 int br_set_forward_delay(struct net_bridge *br, unsigned long x);
 int br_set_hello_time(struct net_bridge *br, unsigned long x);
 int br_set_max_age(struct net_bridge *br, unsigned long x);
-int br_set_ageing_time(struct net_bridge *br, u32 ageing_time);
+int br_set_ageing_time(struct net_bridge *br, clock_t ageing_time);
 
 
 /* br_stp_if.c */
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 9cb7044..9258b8e 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -570,7 +570,7 @@ int br_set_max_age(struct net_bridge *br, unsigned long val)
  *
  * Offloaded switch entries maybe more restrictive
  */
-int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
+int br_set_ageing_time(struct net_bridge *br, clock_t ageing_time)
 {
 	struct switchdev_attr attr = {
 		.orig_dev = br->dev,
-- 
2.9.0
