From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/4] isdn/gigaset: improve error handling when leaving DLE mode
Date: Fri, 3 Oct 2014 17:03:32 +0200
Message-ID: <ee511dbac1d1f24f8ad8b7b15ec3047cc785ae08.1412348612.git.tilman@imap.cc>
References: <cover.1412348612.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:41729 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753271AbaJCQ2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 12:28:16 -0400
In-Reply-To: <cover.1412348612.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid cascading warnings when leaving DLE mode fails by clearing
the DLE flag before entering recovery.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>

---
 drivers/isdn/gigaset/ev-layer.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index 7459b12..dcae14a 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -1243,7 +1243,8 @@ static void do_action(int action, struct cardstate *cs,
 		break;
 	case ACT_FAILDLE0:
 		cs->cur_at_seq = SEQ_NONE;
-		dev_warn(cs->dev, "Could not leave DLE mode.\n");
+		dev_warn(cs->dev, "Error leaving DLE mode.\n");
+		cs->dle = 0;
 		at_state2 = &cs->bcs[cs->curchannel].at_state;
 		disconnect(&at_state2);
 		schedule_init(cs, MS_RECOVER);
-- 
1.9.2.459.g68773ac
