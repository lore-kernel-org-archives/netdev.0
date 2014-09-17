From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 2/2 nf-next] net: bridge: deprecate call_iptables=1 default value
Date: Wed, 17 Sep 2014 17:52:17 +0200
Message-ID: <1410969137-11885-2-git-send-email-fw@strlen.de>
References: <1410969137-11885-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60645 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755464AbaIQPwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 11:52:30 -0400
In-Reply-To: <1410969137-11885-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add a warning and tell users to set call_iptables to 0 or 1
depending on desired behaviour before adding ports to the bridge.

In distant future, this might allow to disable call_iptables by default.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 no changes since v1.

 net/bridge/br_netfilter.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 52c410f..e0b581d 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -58,9 +58,9 @@ static int brnf_filter_vlan_tagged __read_mostly = 0;
 static int brnf_filter_pppoe_tagged __read_mostly = 0;
 static int brnf_pass_vlan_indev __read_mostly = 0;
 
-int brnf_call_iptables __read_mostly = 1;
-int brnf_call_ip6tables __read_mostly = 1;
-int brnf_call_arptables __read_mostly = 1;
+int brnf_call_iptables __read_mostly = 2;
+int brnf_call_ip6tables __read_mostly = 2;
+int brnf_call_arptables __read_mostly = 2;
 #else
 #define brnf_filter_vlan_tagged 0
 #define brnf_filter_pppoe_tagged 0
@@ -1075,6 +1075,12 @@ static void __br_register_hooks_init(struct work_struct *w)
 		return;
 	}
 	static_key_slow_inc(&brnf_hooks_active);
+
+	if ((brnf_call_iptables|brnf_call_ip6tables|brnf_call_arptables) == 2)
+		pr_info("bridge: automatic filtering via arp/ip/ip6tables "
+			"is deprecated and it will be disabled soon. Set "
+			"bridge-nf-call-{ip,ip6,arp}tables sysctls to 1 or 0 "
+			"before adding bridge ports if you need this.\n");
 }
 
 bool br_netfiler_hooks_init(void)
-- 
1.8.1.5
