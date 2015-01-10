From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6] netfilter: nfnetlink: relax strict multicast group check from netlink_bind
Date: Sat, 10 Jan 2015 19:50:07 +0100
Message-ID: <1420915808-7160-6-git-send-email-pablo@netfilter.org>
References: <1420915808-7160-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46783 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754474AbbAJSr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2015 13:47:28 -0500
In-Reply-To: <1420915808-7160-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Relax the checking that was introduced in 97840cb ("netfilter:
nfnetlink: fix insufficient validation in nfnetlink_bind") when the
subscription bitmask is used. Existing userspace code code may request
to listen to all of the existing netlink groups by setting an all to one
subscription group bitmask. Netlink already validates subscription via
setsockopt() for us.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index c6619d4..1aa7049 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -470,7 +470,7 @@ static int nfnetlink_bind(int group)
 	int type;
 
 	if (group <= NFNLGRP_NONE || group > NFNLGRP_MAX)
-		return -EINVAL;
+		return 0;
 
 	type = nfnl_group2type[group];
 
-- 
1.7.10.4
