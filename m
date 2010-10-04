From: Dan Carpenter <error27@gmail.com>
Subject: [patch] cls_u32: signedness bug
Date: Mon, 4 Oct 2010 14:28:36 +0200
Message-ID: <20101004122836.GB5692@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Frans Pop <elendil@planet.nl>, Changli Gao <xiaosuo@gmail.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34112 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755612Ab0JDM3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 08:29:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_headroom() is unsigned so "skb_headroom(skb) + toff" is also
unsigned and can't be less than zero.  This test was added in 66d50d25:
"u32: negative offset fix"  It was supposed to fix a regression.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
Compile tested only.  Please check.

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 7416a5c..b0c2a82 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -137,7 +137,7 @@ next_knode:
 			int toff = off + key->off + (off2 & key->offmask);
 			__be32 *data, _data;
 
-			if (skb_headroom(skb) + toff < 0)
+			if (skb_headroom(skb) + toff > INT_MAX)
 				goto out;
 
 			data = skb_header_pointer(skb, toff, 4, &_data);
