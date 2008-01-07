From: maximilian attems <max@stro.at>
Subject: [PATCH] IRDA: irda_create() nuke user triggable printk
Date: Mon,  7 Jan 2008 01:34:32 +0100
Message-ID: <1199666072-1824-1-git-send-email-max@stro.at>
Cc: netdev@vger.kernel.org, samuel@sortiz.org,
	maximilian attems <max@stro.at>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:55650 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbYAGAek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2008 19:34:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

easy to trigger as user with sfuzz.

irda_create() is quiet on unknown sock->type,
match this behaviour for SOCK_DGRAM unknown protocol

Signed-off-by: maximilian attems <max@stro.at>
---
 net/irda/af_irda.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 48ce59a..d5e4dd7 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1118,8 +1118,6 @@ static int irda_create(struct net *net, struct socket *sock, int protocol)
 			self->max_sdu_size_rx = TTP_SAR_UNBOUND;
 			break;
 		default:
-			IRDA_ERROR("%s: protocol not supported!\n",
-				   __FUNCTION__);
 			return -ESOCKTNOSUPPORT;
 		}
 		break;
-- 
debian.1.5.3.7.1-dirty

