From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 1/3] net: add MODULE_ALIAS_NET_PF_PROTO_NAME
Date: Tue, 29 May 2012 15:30:40 -0400
Message-ID: <1338319842-18395-2-git-send-email-nhorman@tuxdriver.com>
References: <1338319842-18395-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36045 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755320Ab2E2TbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 15:31:07 -0400
In-Reply-To: <1338319842-18395-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MODULE_ALAIS_NET_PF macro set is missing a variant that allows for the
appending of an arbitrary string to the net-pf-<x>-proto-<y> base.  while
MODULE_ALIAS_NET_PF_PROTO_NAME_TYPE allows an appending of a numerical type, we
need to be able to append a generic string to support generic netlink families
that have neither a fix numberical protocol or type number

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: David Miller <davem@davemloft.net>
---
 include/linux/net.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 2d7510f..e9ac2df 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -313,5 +313,8 @@ extern int kernel_sock_shutdown(struct socket *sock,
 	MODULE_ALIAS("net-pf-" __stringify(pf) "-proto-" __stringify(proto) \
 		     "-type-" __stringify(type))
 
+#define MODULE_ALIAS_NET_PF_PROTO_NAME(pf, proto, name) \
+	MODULE_ALIAS("net-pf-" __stringify(pf) "-proto-" __stringify(proto) \
+		     name)
 #endif /* __KERNEL__ */
 #endif	/* _LINUX_NET_H */
-- 
1.7.7.6
