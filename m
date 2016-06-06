From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 1/2] net: cls_u32: fix error code for invalid flags
Date: Mon,  6 Jun 2016 16:16:47 +0100
Message-ID: <1465226208-32097-2-git-send-email-jakub.kicinski@netronome.com>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
Cc: john.r.fastabend@intel.com, sridhar.samudrala@intel.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38718 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbcFFPTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 11:19:08 -0400
Received: by mail-wm0-f43.google.com with SMTP id m124so76954876wme.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 08:19:07 -0700 (PDT)
In-Reply-To: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'err' variable is not set in this test, we would return whatever
previous test set 'err' to.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 net/sched/cls_u32.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 079b43b3c5d2..b17e090f2fe1 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -863,7 +863,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	if (tb[TCA_U32_FLAGS]) {
 		flags = nla_get_u32(tb[TCA_U32_FLAGS]);
 		if (!tc_flags_valid(flags))
-			return err;
+			return -EINVAL;
 	}
 
 	n = (struct tc_u_knode *)*arg;
-- 
1.9.1
