From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2.6.28 1/4] myri10ge: Stop scaring people when DCA is built
 but absent
Date: Fri, 12 Sep 2008 19:47:26 +0200
Message-ID: <48CAAB2E.6010408@myri.com>
References: <48CAAAEF.1060205@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1896 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753441AbYILRsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2008 13:48:33 -0400
In-Reply-To: <48CAAAEF.1060205@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stop scaring people with what looks like a fatal message when DCA support
is compiled into their kernel, but the DCA device is not present.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

Index: linux-2.6.git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.git.orig/drivers/net/myri10ge/myri10ge.c	2008-08-29 07:29:45.000000000 +0200
+++ linux-2.6.git/drivers/net/myri10ge/myri10ge.c	2008-09-12 19:22:37.000000000 +0200
@@ -1060,8 +1060,9 @@
 	}
 	err = dca_add_requester(&pdev->dev);
 	if (err) {
-		dev_err(&pdev->dev,
-			"dca_add_requester() failed, err=%d\n", err);
+		if (err != -ENODEV)
+			dev_err(&pdev->dev,
+				"dca_add_requester() failed, err=%d\n", err);
 		return;
 	}
 	mgp->dca_enabled = 1;


