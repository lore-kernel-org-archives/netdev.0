From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 2/4] ipv4: fib_semantics: increment fib_info_cnt after fib_info allocation
Date: Tue, 21 Jan 2014 13:48:49 +0200
Message-ID: <c1dc3e2bab186c0e08fd6fb5f0221bc7441a3b2d.1390304505.git.popovich_sergei@mail.ru>
References: <cover.1390304505.git.popovich_sergei@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback3.mail.ru ([94.100.176.58]:36977 "EHLO
	fallback3.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754103AbaAULtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 06:49:19 -0500
Received: from smtp11.mail.ru (smtp11.mail.ru [94.100.176.85])
	by fallback3.mail.ru (mPOP.Fallback_MX) with ESMTP id 0A8CB1097BB96
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 15:49:18 +0400 (MSK)
Received: from [2a01:6d80:103:13::c3ea:4404] (port=42200 helo=tuxracer.localdomain)
	by smtp11.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1W5ZpA-0006Kt-LQ
	for netdev@vger.kernel.org; Tue, 21 Jan 2014 15:48:56 +0400
In-Reply-To: <cover.1390304505.git.popovich_sergei@mail.ru>
In-Reply-To: <cover.1390304505.git.popovich_sergei@mail.ru>
References: <cover.1390304505.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increment fib_info_cnt in fib_create_info() right after successfuly
alllocating fib_info structure, overwise fib_metrics allocation failure
leads to fib_info_cnt incorrectly decremented in free_fib_info(), called
on error path from fib_create_info().

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
---
 net/ipv4/fib_semantics.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index b53f0bf..9d43468 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -820,13 +820,13 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	fi = kzalloc(sizeof(*fi)+nhs*sizeof(struct fib_nh), GFP_KERNEL);
 	if (fi == NULL)
 		goto failure;
+	fib_info_cnt++;
 	if (cfg->fc_mx) {
 		fi->fib_metrics = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
 		if (!fi->fib_metrics)
 			goto failure;
 	} else
 		fi->fib_metrics = (u32 *) dst_default_metrics;
-	fib_info_cnt++;
 
 	fi->fib_net = hold_net(net);
 	fi->fib_protocol = cfg->fc_protocol;
-- 
1.8.3.4
