From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -master] netfilter: xt_CT: checking for IS_ERR() instead of
 NULL
Date: Tue, 28 Jul 2015 01:42:28 +0300
Message-ID: <20150727224228.GA10367@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35681 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124AbbG0Wne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 18:43:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We recently changed this from nf_conntrack_alloc() to nf_ct_tmpl_alloc()
so the error handling needs to changed to check for NULL instead of
IS_ERR().

Fixes: 0838aa7fcfcd ('netfilter: fix netns dependencies with conntrack templates')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index c663003..43ddeee 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -202,9 +202,10 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 		goto err1;
 
 	ct = nf_ct_tmpl_alloc(par->net, info->zone, GFP_KERNEL);
-	ret = PTR_ERR(ct);
-	if (IS_ERR(ct))
+	if (!ct) {
+		ret = -ENOMEM;
 		goto err2;
+	}
 
 	ret = 0;
 	if ((info->ct_events || info->exp_events) &&
