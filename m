From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 4/8 net-2.6.26] [NETNS]: Add netns refcnt debug into fib_info.
Date: Tue, 15 Apr 2008 16:37:51 +0400
Message-ID: <1208263075-28016-4-git-send-email-den@openvz.org>
References: <1208262959.21529.32.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	dlezcano@fr.ibm.com, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47965 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760025AbYDOMjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:39:00 -0400
In-Reply-To: <1208262959.21529.32.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/fib_semantics.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index a13c847..3b83c34 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -152,6 +152,7 @@ void free_fib_info(struct fib_info *fi)
 		nh->nh_dev = NULL;
 	} endfor_nexthops(fi);
 	fib_info_cnt--;
+	release_net(fi->fib_net);
 	kfree(fi);
 }
 
@@ -730,7 +731,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		goto failure;
 	fib_info_cnt++;
 
-	fi->fib_net = net;
+	fi->fib_net = hold_net(net);
 	fi->fib_protocol = cfg->fc_protocol;
 	fi->fib_flags = cfg->fc_flags;
 	fi->fib_priority = cfg->fc_priority;
-- 
1.5.3.rc5

