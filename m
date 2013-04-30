From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] netlink: Fix skb ref counting.
Date: Mon, 29 Apr 2013 23:52:01 -0700
Message-ID: <1367304721-9213-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:58466 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753594Ab3D3GwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 02:52:14 -0400
Received: by mail-pa0-f71.google.com with SMTP id hk2so256827pac.2
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 23:52:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f9c2288837ba072b21dba955f04a4c97eaa77b1e (netlink:
implement memory mapped recvmsg) increamented skb->users
ref count twice for a dump op which does not look right.

Following patch fixes that.

CC: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/netlink/af_netlink.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index d9c7869..12ac6b4 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2504,7 +2504,6 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	cb->data = control->data;
 	cb->module = control->module;
 	cb->min_dump_alloc = control->min_dump_alloc;
-	atomic_inc(&skb->users);
 	cb->skb = skb;
 
 	sk = netlink_lookup(sock_net(ssk), ssk->sk_protocol, NETLINK_CB(skb).portid);
-- 
1.7.1
