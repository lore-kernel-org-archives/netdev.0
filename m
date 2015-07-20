From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] bridge: mcast: fix br_multicast_dev_del
	warn when igmp snooping is not defined
Date: Mon, 20 Jul 2015 23:03:45 +0200
Message-ID: <1437426225-28418-1-git-send-email-razor@blackwall.org>
References: <201507210410.H5dNw6Lx%fengguang.wu@intel.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <201507210410.H5dNw6Lx%fengguang.wu@intel.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Fix:
net/bridge/br_if.c: In function 'br_dev_delete':
>> net/bridge/br_if.c:284:2: error: implicit declaration of function
>> 'br_multicast_dev_del' [-Werror=implicit-function-declaration]
     br_multicast_dev_del(br);
     ^
   cc1: some warnings being treated as errors

when igmp snooping is not defined.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
Apologies for the mess.

 net/bridge/br_private.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2bada2279721..3ad1290528af 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -566,6 +566,10 @@ static inline void br_multicast_stop(struct net_bridge *br)
 {
 }
 
+static inline void br_multicast_dev_del(struct net_bridge *br)
+{
+}
+
 static inline void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
 					struct sk_buff *skb)
 {
-- 
1.9.3
