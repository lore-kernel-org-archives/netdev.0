From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v1 4/8] xen-netback: reduce log spam
Date: Fri, 12 Feb 2016 10:13:21 +0000
Message-ID: <1455272005-17144-5-git-send-email-paul.durrant@citrix.com>
References: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:2563 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220AbcBLKVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 05:21:40 -0500
In-Reply-To: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the "prepare for reconnect" pr_info in xenbus.c. It's largely
uninteresting and the states of the frontend and backend can easily be
observed by watching the (o)xenstored log.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/xenbus.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 39a303d..bd182cd 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -511,8 +511,6 @@ static void set_backend_state(struct backend_info *be,
 			switch (state) {
 			case XenbusStateInitWait:
 			case XenbusStateConnected:
-				pr_info("%s: prepare for reconnect\n",
-					be->dev->nodename);
 				backend_switch_state(be, XenbusStateInitWait);
 				break;
 			case XenbusStateClosing:
-- 
2.1.4
