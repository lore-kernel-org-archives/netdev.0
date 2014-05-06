From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH] ipv4: fib_semantics: increment fib_info_cnt after fib_info allocation
Date: Tue,  6 May 2014 18:23:08 +0300
Message-ID: <1399389788-20363-1-git-send-email-popovich_sergei@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp39.i.mail.ru ([94.100.177.99]:60526 "EHLO smtp39.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757573AbaEFPXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 11:23:18 -0400
Received: from [195.234.68.4] (port=52783 helo=tuxracer.skif.com.ua)
	by smtp39.i.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1WhhD9-0005kL-NF
	for netdev@vger.kernel.org; Tue, 06 May 2014 19:23:16 +0400
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
