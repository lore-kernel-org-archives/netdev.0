From: akpm@linux-foundation.org
Subject: [patch 4/6] mISDN: fix reversed if in st_own_ctrl()
Date: Fri, 18 Sep 2009 12:53:04 -0700
Message-ID: <200909181953.n8IJr4cS026252@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	error27@gmail.com
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57372 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757715AbZIRUB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2009 16:01:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>

The current code probably returns -EINVAL a lot.  Otherwise it would oops.

Compile tested only.  Found by smatch (http://repo.or.cz/w/smatch.git).

Signed-off-by: Dan Carpenter <error27@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/mISDN/stack.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/isdn/mISDN/stack.c~misdn-fix-reversed-if-in-st_own_ctrl drivers/isdn/mISDN/stack.c
--- a/drivers/isdn/mISDN/stack.c~misdn-fix-reversed-if-in-st_own_ctrl
+++ a/drivers/isdn/mISDN/stack.c
@@ -364,7 +364,7 @@ add_layer2(struct mISDNchannel *ch, stru
 static int
 st_own_ctrl(struct mISDNchannel *ch, u_int cmd, void *arg)
 {
-	if (!ch->st || ch->st->layer1)
+	if (!ch->st || !ch->st->layer1)
 		return -EINVAL;
 	return ch->st->layer1->ctrl(ch->st->layer1, cmd, arg);
 }
_
