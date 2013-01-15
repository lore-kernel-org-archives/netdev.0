From: Cong Ding <dinggnu@gmail.com>
Subject: [PATCH] net: netfilter/xt_CT.c: fix uninitialized variable
Date: Tue, 15 Jan 2013 19:58:34 +0100
Message-ID: <1358276314-9536-1-git-send-email-dinggnu@gmail.com>
Cc: Cong Ding <dinggnu@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If CONFIG_NF_CONNTRACK_ZONES is not defined, the variable ret might be
uninitialized when it goes to err1 through line 125 and 263 respectively.
So I change these goto err1 to return -EINVAL directly.

Signed-off-by: Cong Ding <dinggnu@gmail.com>
---
 net/netfilter/xt_CT.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 2a08430..941f600 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -122,7 +122,7 @@ static int xt_ct_tg_check_v0(const struct xt_tgchk_param *par)
 
 #ifndef CONFIG_NF_CONNTRACK_ZONES
 	if (info->zone)
-		goto err1;
+		return -EINVAL;
 #endif
 
 	ret = nf_ct_l3proto_try_module_get(par->family);
@@ -260,7 +260,7 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 
 #ifndef CONFIG_NF_CONNTRACK_ZONES
 	if (info->zone)
-		goto err1;
+		return -EINVAL;
 #endif
 
 	ret = nf_ct_l3proto_try_module_get(par->family);
-- 
1.7.10.4
