From: Hannes Eder <heder@google.com>
Subject: [PATCH v2] IPVS: logging sizeof(struct ip_vs_conn) on startup
Date: Mon, 27 Jul 2009 15:13:57 +0200
Message-ID: <20090727131357.9561.39720.stgit@jazzy.zrh.corp.google.com>
References: <20090727090741.16509.35291.stgit@jazzy.zrh.corp.google.com>
	 <4A6D7285.9080909@gmail.com>
	 <b5ddba180907270334m4bc4e968m85c16ea4756c3f5d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:31877 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847AbZG0NPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 09:15:51 -0400
Cc: lvs-users@linuxvirtualserver.org
Cc: malcolm@loadbalancer.org
Cc: linux-kernel@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>
In-Reply-To: <b5ddba180907270334m4bc4e968m85c16ea4756c3f5d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No more guessing, how much memory used by IPVS for a connection.

[ The number printed is a lower bound, as ip_vs_conn_cache uses
SLAB_HWCACHE_ALIGN. ]

Signed-off-by: Hannes Eder <heder@google.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

 net/netfilter/ipvs/ip_vs_core.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b021464..b6bb4a0 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1475,7 +1475,8 @@ static int __init ip_vs_init(void)
 		goto cleanup_conn;
 	}
 
-	IP_VS_INFO("ipvs loaded.\n");
+	IP_VS_INFO("ipvs loaded (using at least %Zd bytes/connection).\n",
+	       sizeof(struct ip_vs_conn));
 	return ret;
 
   cleanup_conn:

