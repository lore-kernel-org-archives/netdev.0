From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/04: conntrack: don't deliver events for racy packets
Date: Mon, 16 Mar 2009 17:08:43 +0100 (MET)
Message-ID: <20090316160842.3567.21460.sendpatchset@x2.localnet>
References: <20090316160841.3567.94089.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090316160841.3567.94089.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit b1e93a68ca41e7e73766f95ba32ca05cf9052e15
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Mar 16 15:06:42 2009 +0100

    netfilter: conntrack: don't deliver events for racy packets
    
    This patch skips the delivery of conntrack events if the packet
    was drop due to a race condition in the conntrack insertion.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index c25068e..5a449b4 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -62,7 +62,8 @@ static inline int nf_conntrack_confirm(struct sk_buff *skb)
 	if (ct && ct != &nf_conntrack_untracked) {
 		if (!nf_ct_is_confirmed(ct) && !nf_ct_is_dying(ct))
 			ret = __nf_conntrack_confirm(skb);
-		nf_ct_deliver_cached_events(ct);
+		if (likely(ret == NF_ACCEPT))
+			nf_ct_deliver_cached_events(ct);
 	}
 	return ret;
 }
