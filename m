From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/03: restore POST_ROUTING hook in NF_HOOK_COND
Date: Fri, 19 Feb 2010 18:02:08 +0100 (MET)
Message-ID: <20100219170208.18096.29854.sendpatchset@x2.localnet>
References: <20100219170206.18096.12788.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100219170206.18096.12788.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 4bac6b180771f7ef5275b1a6d88e630ca3a3d6f0
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Feb 19 08:03:28 2010 +0100

    netfilter: restore POST_ROUTING hook in NF_HOOK_COND
    
    Commit 2249065 ("netfilter: get rid of the grossness in netfilter.h")
    inverted the logic for conditional hook invocation, breaking the
    POST_ROUTING hook invoked by ip_output().
    
    Correct the logic and remove an unnecessary initialization.
    
    Reported-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 7007945..89341c3 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -212,8 +212,9 @@ NF_HOOK_COND(uint8_t pf, unsigned int hook, struct sk_buff *skb,
 	     struct net_device *in, struct net_device *out,
 	     int (*okfn)(struct sk_buff *), bool cond)
 {
-	int ret = 1;
-	if (cond ||
+	int ret;
+
+	if (!cond ||
 	    (ret = nf_hook_thresh(pf, hook, skb, in, out, okfn, INT_MIN) == 1))
 		ret = okfn(skb);
 	return ret;
