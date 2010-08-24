From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipvs: switch to GFP_KERNEL allocations
Date: Tue, 24 Aug 2010 07:51:38 +0200
Message-ID: <1282629098.2378.1521.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch from GFP_ATOMIC allocations to GFP_KERNEL ones in
ip_vs_add_service() and ip_vs_new_dest(), as we hold a mutex and are
allowed to sleep in this context.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 0f0c079..896f34b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -843,7 +843,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 			return -EINVAL;
 	}
 
-	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_ATOMIC);
+	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_KERNEL);
 	if (dest == NULL) {
 		pr_err("%s(): no memory.\n", __func__);
 		return -ENOMEM;
@@ -1177,7 +1177,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 	}
 #endif
 
-	svc = kzalloc(sizeof(struct ip_vs_service), GFP_ATOMIC);
+	svc = kzalloc(sizeof(struct ip_vs_service), GFP_KERNEL);
 	if (svc == NULL) {
 		IP_VS_DBG(1, "%s(): no memory\n", __func__);
 		ret = -ENOMEM;


