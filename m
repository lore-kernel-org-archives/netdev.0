From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/09: bridge: Disable PPPOE/VLAN processing by default
Date: Mon, 12 Jan 2009 11:06:03 +0100 (MET)
Message-ID: <20090112100603.9280.52407.sendpatchset@x2.localnet>
References: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60695 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607AbZALKGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 05:06:04 -0500
In-Reply-To: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 12eda8e57aaca177ed94db3d9883873cd4522c99
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Mon Jan 12 06:28:48 2009 +0100

    netfilter: bridge: Disable PPPOE/VLAN processing by default
    
    The PPPOE/VLAN processing code in the bridge netfilter is broken
    by design.  The VLAN tag and the PPPOE session ID are an integral
    part of the packet flow information, yet they're completely
    ignored by the bridge netfilter.  This is potentially a security
    hole as it treats all VLANs and PPPOE sessions as the same.
    
    What's more, it's actually broken for PPPOE as the bridge netfilter
    tries to trim the packets to the IP length without adjusting the
    PPPOE header (and adjusting the PPPOE header isn't much better
    since the PPPOE peer may require the padding to be present).
    
    Therefore we should disable this by default.
    
    It does mean that people relying on this feature may lose networking
    depending on how their bridge netfilter rules are configured.
    However, IMHO the problems this code causes are serious enough to
    warrant this.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 9a1cd75..cf754ac 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -58,11 +58,11 @@ static struct ctl_table_header *brnf_sysctl_header;
 static int brnf_call_iptables __read_mostly = 1;
 static int brnf_call_ip6tables __read_mostly = 1;
 static int brnf_call_arptables __read_mostly = 1;
-static int brnf_filter_vlan_tagged __read_mostly = 1;
-static int brnf_filter_pppoe_tagged __read_mostly = 1;
+static int brnf_filter_vlan_tagged __read_mostly = 0;
+static int brnf_filter_pppoe_tagged __read_mostly = 0;
 #else
-#define brnf_filter_vlan_tagged 1
-#define brnf_filter_pppoe_tagged 1
+#define brnf_filter_vlan_tagged 0
+#define brnf_filter_pppoe_tagged 0
 #endif
 
 static inline __be16 vlan_proto(const struct sk_buff *skb)
