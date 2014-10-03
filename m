From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 4/4] isdn/capi: drop two dead if branches
Date: Fri, 3 Oct 2014 17:03:32 +0200
Message-ID: <20141003153135.60EC114006D@xenon.ts.pxnet.com>
References: <cover.1412348612.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:41729 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753461AbaJCQ2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 12:28:13 -0400
In-Reply-To: <cover.1412348612.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The last branch in command_2_index() cannot be reached since
c==0xff is already caught by the first "if".
The empty second branch makes no difference since no other branch
will be taken for c<0x0f.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/capiutil.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/isdn/capi/capiutil.c b/drivers/isdn/capi/capiutil.c
index 6e797e5..4073d16 100644
--- a/drivers/isdn/capi/capiutil.c
+++ b/drivers/isdn/capi/capiutil.c
@@ -205,11 +205,8 @@ static unsigned command_2_index(unsigned c, unsigned sc)
 {
 	if (c & 0x80)
 		c = 0x9 + (c & 0x0f);
-	else if (c <= 0x0f);
 	else if (c == 0x41)
 		c = 0x9 + 0x1;
-	else if (c == 0xff)
-		c = 0x00;
 	return (sc & 3) * (0x9 + 0x9) + c;
 }
 
-- 
1.9.2.459.g68773ac
