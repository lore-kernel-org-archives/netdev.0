From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/05: ctnetlink: fix echo if not subscribed to any	multicast group
Date: Mon,  9 Feb 2009 17:39:32 +0100 (MET)
Message-ID: <20090209163931.13918.35499.sendpatchset@x2.localnet>
References: <20090209163926.13918.96177.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090209163926.13918.96177.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 8f0613c03d2bb8ab39f6e21ff555026dce503179
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Feb 9 14:26:52 2009 +0100

    netfilter: ctnetlink: fix echo if not subscribed to any	multicast group
    
    This patch fixes echoing if the socket that has sent the request to
    create/update/delete an entry is not subscribed to any multicast
    group. With the current code, ctnetlink would not send the echo
    message via unicast as nfnetlink_send() would be skip.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 9051bb4..cb78aa0 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -434,7 +434,7 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	} else
 		return NOTIFY_DONE;
 
-	if (!nfnetlink_has_listeners(group))
+	if (!item->report && !nfnetlink_has_listeners(group))
 		return NOTIFY_DONE;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
@@ -1502,7 +1502,8 @@ static int ctnetlink_expect_event(struct notifier_block *this,
 	} else
 		return NOTIFY_DONE;
 
-	if (!nfnetlink_has_listeners(NFNLGRP_CONNTRACK_EXP_NEW))
+	if (!item->report &&
+	    !nfnetlink_has_listeners(NFNLGRP_CONNTRACK_EXP_NEW))
 		return NOTIFY_DONE;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
