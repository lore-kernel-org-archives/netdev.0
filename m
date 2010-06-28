From: Dan Carpenter <error27@gmail.com>
Subject: [patch] isdn/gigaset: add a kfree() to error path
Date: Mon, 28 Jun 2010 23:20:46 +0200
Message-ID: <20100628212046.GM19184@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tilman Schmidt <tilman@imap.cc>,
	Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Hansjoerg Lipp <hjlipp@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:37116 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380Ab0F1VWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 17:22:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should free "commands" here.  The main reason is to please the static
checkers.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index f01c3c2..f1abb8f 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -419,6 +419,7 @@ oom:
 	dev_err(bcs->cs->dev, "out of memory\n");
 	for (i = 0; i < AT_NUM; ++i)
 		kfree(commands[i]);
+	kfree(commands);
 	return -ENOMEM;
 }
 
