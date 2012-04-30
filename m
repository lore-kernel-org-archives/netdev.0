From: pablo@netfilter.org
Subject: [PATCH 3/8] ipvs: add check in ftp for initialized core
Date: Mon, 30 Apr 2012 17:16:50 +0200
Message-ID: <1335799015-2003-4-git-send-email-pablo@netfilter.org>
References: <1335799015-2003-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1335799015-2003-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

	Avoid crash when registering ip_vs_ftp after
the IPVS core initialization for netns fails. Do this by
checking for present core (net->ipvs).

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ftp.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 538d74e..e39f693 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -439,6 +439,8 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
 	struct ip_vs_app *app;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	if (!ipvs)
+		return -ENOENT;
 	app = kmemdup(&ip_vs_ftp, sizeof(struct ip_vs_app), GFP_KERNEL);
 	if (!app)
 		return -ENOMEM;
-- 
1.7.9.5

