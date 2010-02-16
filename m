From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 47/62: xtables: fix mangle tables
Date: Tue, 16 Feb 2010 15:56:23 +0100 (MET)
Message-ID: <20100216145621.2796.79195.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit b2907e501945d5d13326a6a7441c13e41cd0e799
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Thu Feb 11 18:41:35 2010 +0100

    netfilter: xtables: fix mangle tables
    
    In POST_ROUTING hook, calling dev_net(in) is going to oops.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 58d7097..c833330 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -87,7 +87,9 @@ iptable_mangle_hook(unsigned int hook,
 {
 	if (hook == NF_INET_LOCAL_OUT)
 		return ipt_local_hook(hook, skb, in, out, okfn);
-
+	if (hook == NF_INET_POST_ROUTING)
+		return ipt_do_table(skb, hook, in, out,
+				    dev_net(out)->ipv4.iptable_mangle);
 	/* PREROUTING/INPUT/FORWARD: */
 	return ipt_do_table(skb, hook, in, out,
 			    dev_net(in)->ipv4.iptable_mangle);
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index dc803b7..b6216de 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -81,7 +81,9 @@ ip6table_mangle_hook(unsigned int hook, struct sk_buff *skb,
 {
 	if (hook == NF_INET_LOCAL_OUT)
 		return ip6t_local_out_hook(hook, skb, out, okfn);
-
+	if (hook == NF_INET_POST_ROUTING)
+		return ip6t_do_table(skb, hook, in, out,
+				     dev_net(out)->ipv6.ip6table_mangle);
 	/* INPUT/FORWARD */
 	return ip6t_do_table(skb, hook, in, out,
 			     dev_net(in)->ipv6.ip6table_mangle);
