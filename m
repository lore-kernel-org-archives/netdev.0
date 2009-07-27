From: Hannes Eder <heder@google.com>
Subject: [PATCH] IPVS: logging sizeof(struct ip_vs_conn) on startup
Date: Mon, 27 Jul 2009 11:08:34 +0200
Message-ID: <20090727090741.16509.35291.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: lvs-users@linuxvirtualserver.org, malcolm@loadbalancer.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:4442 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289AbZG0JIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 05:08:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No more guessing, how much memory is used by IPVS for a connection.

Signed-off-by: Hannes Eder <heder@google.com>
---
 net/netfilter/ipvs/ip_vs_core.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b021464..5b0997c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1475,7 +1475,8 @@ static int __init ip_vs_init(void)
 		goto cleanup_conn;
 	}
 
-	IP_VS_INFO("ipvs loaded.\n");
+	IP_VS_INFO("ipvs loaded (using %Zd bytes/connection).\n",
+	       sizeof(struct ip_vs_conn));
 	return ret;
 
   cleanup_conn:

