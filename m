From: Matvejchikov Ilya <matvejchikov@gmail.com>
Subject: [PATCH] NET: slip, fix ldisc->open retval
Date: Fri, 6 May 2011 20:23:09 +0400
Message-ID: <BANLkTinWqaoMNHbOb5PbZzewQafWhBfY4Q@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:35551 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756326Ab1EFQXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 12:23:31 -0400
Received: by iwn34 with SMTP id 34so2799435iwn.19
        for <netdev@vger.kernel.org>; Fri, 06 May 2011 09:23:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TTY layer expects 0 if the ldisc->open operation succeeded.

Signed-off-by : Matvejchikov Ilya <matvejchikov@gmail.com>
---
 drivers/net/slip.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index 86cbb9e..8ec1a9a 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -853,7 +853,9 @@ static int slip_open(struct tty_struct *tty)
 	/* Done.  We have linked the TTY line to a channel. */
 	rtnl_unlock();
 	tty->receive_room = 65536;	/* We don't flow control */
-	return sl->dev->base_addr;
+
+	/* TTY layer expects 0 on success */
+	return 0;

 err_free_bufs:
 	sl_free_bufs(sl);
-- 
1.7.5.1
