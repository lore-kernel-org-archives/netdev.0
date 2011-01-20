From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: add a missing include in nf_conntrack_reasm.c
Date: Thu, 20 Jan 2011 18:53:17 +0100
Message-ID: <1295545997.2825.458.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	KOVACS Krisztian <hidden@balabit.hu>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60699 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844Ab1ATRyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 12:54:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    1 +
 1 file changed, 1 insertion(+)

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


