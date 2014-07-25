From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] [linux-next] netfilter: kill remnants of ulog
	targets
Date: Fri, 25 Jul 2014 14:25:31 +0200
Message-ID: <1406291131.8231.20.camel@x220>
References: <1406107694.12441.8.camel@x220> <20140723093949.GA3754@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller"
	<davem@davemloft.net>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik
	<kadlec@blackhole.kfki.hu>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140723093949.GA3754@salvia>
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

The ulog targets were recently killed. A few references to the Kconfig
macros CONFIG_IP_NF_TARGET_ULOG and CONFIG_BRIDGE_EBT_ULOG were left
untouched. Kill these too.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Note that ulog_warn_deprecated and ebt_ulog_warn_deprecated do not exist
anymore. Neither do */ebt_ulog.c and */ipt_ULOG.c.

 include/net/netns/x_tables.h  | 6 ------
 net/bridge/netfilter/Makefile | 1 -
 net/ipv4/netfilter/Makefile   | 1 -
 3 files changed, 8 deletions(-)

diff --git a/include/net/netns/x_tables.h b/include/net/netns/x_tables.h
index 02fe40f8c8fd..c24060ee411e 100644
--- a/include/net/netns/x_tables.h
+++ b/include/net/netns/x_tables.h
@@ -15,11 +15,5 @@ struct netns_xt {
 	struct ebt_table *frame_filter;
 	struct ebt_table *frame_nat;
 #endif
-#if IS_ENABLED(CONFIG_IP_NF_TARGET_ULOG)
-	bool ulog_warn_deprecated;
-#endif
-#if IS_ENABLED(CONFIG_BRIDGE_EBT_ULOG)
-	bool ebt_ulog_warn_deprecated;
-#endif
 };
 #endif
diff --git a/net/bridge/netfilter/Makefile b/net/bridge/netfilter/Makefile
index 1f78ea0d90e4..e0560a60cad4 100644
--- a/net/bridge/netfilter/Makefile
+++ b/net/bridge/netfilter/Makefile
@@ -36,5 +36,4 @@ obj-$(CONFIG_BRIDGE_EBT_SNAT) += ebt_snat.o
 
 # watchers
 obj-$(CONFIG_BRIDGE_EBT_LOG) += ebt_log.o
-obj-$(CONFIG_BRIDGE_EBT_ULOG) += ebt_ulog.o
 obj-$(CONFIG_BRIDGE_EBT_NFLOG) += ebt_nflog.o
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 245db9df3337..33001621465b 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -57,7 +57,6 @@ obj-$(CONFIG_IP_NF_TARGET_ECN) += ipt_ECN.o
 obj-$(CONFIG_IP_NF_TARGET_MASQUERADE) += ipt_MASQUERADE.o
 obj-$(CONFIG_IP_NF_TARGET_REJECT) += ipt_REJECT.o
 obj-$(CONFIG_IP_NF_TARGET_SYNPROXY) += ipt_SYNPROXY.o
-obj-$(CONFIG_IP_NF_TARGET_ULOG) += ipt_ULOG.o
 
 # generic ARP tables
 obj-$(CONFIG_IP_NF_ARPTABLES) += arp_tables.o
-- 
1.9.3
