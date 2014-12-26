From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 27/27] mwifiex: main: Use setup_timer
Date: Fri, 26 Dec 2014 15:35:56 +0100
Message-ID: <1419604558-29743-26-git-send-email-Julia.Lawall@lip6.fr>
References: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Avinash Patil <patila@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Amitkumar Karwar <akarwar@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:17526 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752055AbaLZOmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2014 09:42:38 -0500
In-Reply-To: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert a call to init_timer and accompanying intializations of
the timer's data and function fields to a call to setup_timer.

A simplified version of the semantic match that fixes this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression t,f,d;
@@

-init_timer(&t);
+setup_timer(&t,f,d);
-t.function = f;
-t.data = d;
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wireless/mwifiex/main.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwifiex/main.c
index d4d2223..53f4202 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -83,9 +83,8 @@ static int mwifiex_register(void *card, struct mwifiex_if_ops *if_ops,
 	}
 	mwifiex_init_lock_list(adapter);
 
-	init_timer(&adapter->cmd_timer);
-	adapter->cmd_timer.function = mwifiex_cmd_timeout_func;
-	adapter->cmd_timer.data = (unsigned long) adapter;
+	setup_timer(&adapter->cmd_timer, mwifiex_cmd_timeout_func,
+		    (unsigned long)adapter);
 
 	return 0;
 
