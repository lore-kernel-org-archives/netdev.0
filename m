From: Julius Volz <juliusv@google.com>
Subject: [PATCH] IRDA: Fix genlmsg_put() return value check.
Date: Tue, 24 Jun 2008 11:29:14 +0200
Message-ID: <1214299754-27769-1-git-send-email-juliusv@google.com>
References: <f4845fc0806231329p7ef94a8dqafe63feea89ad949@mail.gmail.com>
Cc: kaber@trash.net, samuel@sortiz.org, netdev@vger.kernel.org,
	Julius Volz <juliusv@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:8985 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbYFXJ3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 05:29:37 -0400
In-Reply-To: <f4845fc0806231329p7ef94a8dqafe63feea89ad949@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix an incorrect return value check of genlmsg_put() in irda_nl_get_mode().
genlmsg_put() does not use ERR_PTR() to encode return values, it just
returns NULL on error.

Signed-off-by: Julius Volz <juliusv@google.com>
---
 net/irda/irnetlink.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/irda/irnetlink.c b/net/irda/irnetlink.c
index 9e1fb82..ea11cb4 100644
--- a/net/irda/irnetlink.c
+++ b/net/irda/irnetlink.c
@@ -101,8 +101,8 @@ static int irda_nl_get_mode(struct sk_buff *skb, struct genl_info *info)
 
 	hdr = genlmsg_put(msg, info->snd_pid, info->snd_seq,
 			  &irda_nl_family, 0,  IRDA_NL_CMD_GET_MODE);
-	if (IS_ERR(hdr)) {
-		ret = PTR_ERR(hdr);
+	if (hdr == NULL) {
+		ret = -EMSGSIZE;
 		goto err_out;
 	}
 
-- 
1.5.3.6

