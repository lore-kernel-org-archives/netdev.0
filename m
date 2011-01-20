From: kaber@trash.net
Subject: [PATCH 7/7] netfilter: add a missing include in nf_conntrack_reasm.c
Date: Thu, 20 Jan 2011 21:22:46 +0100
Message-ID: <1295554966-5263-8-git-send-email-kaber@trash.net>
References: <1295554966-5263-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	KOVACS Krisztian <hidden@balabit.hu>,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44118 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754675Ab1ATU0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 15:26:48 -0500
In-Reply-To: <1295554966-5263-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

After commit ae90bdeaeac6b (netfilter: fix compilation when conntrack is
disabled but tproxy is enabled) we have following warnings :

net/ipv6/netfilter/nf_conntrack_reasm.c:520:16: warning: symbol
'nf_ct_frag6_gather' was not declared. Should it be static?
net/ipv6/netfilter/nf_conntrack_reasm.c:591:6: warning: symbol
'nf_ct_frag6_output' was not declared. Should it be static?
net/ipv6/netfilter/nf_conntrack_reasm.c:612:5: warning: symbol
'nf_ct_frag6_init' was not declared. Should it be static?
net/ipv6/netfilter/nf_conntrack_reasm.c:640:6: warning: symbol
'nf_ct_frag6_cleanup' was not declared. Should it be static?

Fix this including net/netfilter/ipv6/nf_defrag_ipv6.h

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: KOVACS Krisztian <hidden@balabit.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 66e003e..0857272 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -45,6 +45,7 @@
 #include <linux/netfilter_ipv6.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 
 
 struct nf_ct_frag6_skb_cb
-- 
1.7.3.4

