From: "Samuel Ortiz" <samuel@sortiz.org>
Subject: [PATCH 4/4] irda: Fix netlink error path return value
Date: Mon, 30 Jun 2008 21:23:55 +0200
Message-ID: <20080630192754.518128980@sortiz.org>
References: <20080630192351.765611690@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	Julius Volz <juliusv@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp21.orange.fr ([80.12.242.46]:29379 "EHLO smtp21.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752139AbYF3T0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2008 15:26:24 -0400
Content-Disposition: inline; filename=irda_nl.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julius Volz <juliusv@google.com>

Fix an incorrect return value check of genlmsg_put() in irda_nl_get_mode().
genlmsg_put() does not use ERR_PTR() to encode return values, it just
returns NULL on error.

Signed-off-by: Julius Volz <juliusv@google.com>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 net/irda/irnetlink.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: net-next-2.6/net/irda/irnetlink.c
===================================================================
--- net-next-2.6.orig/net/irda/irnetlink.c	2008-06-14 13:20:33.000000000 +0200
+++ net-next-2.6/net/irda/irnetlink.c	2008-06-30 21:03:13.000000000 +0200
@@ -101,8 +101,8 @@ static int irda_nl_get_mode(struct sk_bu
 
 	hdr = genlmsg_put(msg, info->snd_pid, info->snd_seq,
 			  &irda_nl_family, 0,  IRDA_NL_CMD_GET_MODE);
-	if (IS_ERR(hdr)) {
-		ret = PTR_ERR(hdr);
+	if (hdr == NULL) {
+		ret = -EMSGSIZE;
 		goto err_out;
 	}
 

-- 

