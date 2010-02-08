From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 33/41] CAPI: Rename datahandle_queue -> ackqueue_entry
Date: Mon,  8 Feb 2010 21:12:37 +0100
Message-ID: <88d410350e34403b4ea8650de90a524b3995690a.1265659936.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:43412 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754708Ab0BHUNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:14 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This struct is describing a queue entry, not the queue itself.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index c5c54fa..9d4750a 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -76,7 +76,7 @@ struct capidev;
 struct capincci;
 struct capiminor;
 
-struct datahandle_queue {
+struct ackqueue_entry {
 	struct list_head	list;
 	u16			datahandle;
 };
@@ -156,7 +156,7 @@ static struct tty_driver *capinc_tty_driver;
 
 static int capiminor_add_ack(struct capiminor *mp, u16 datahandle)
 {
-	struct datahandle_queue *n;
+	struct ackqueue_entry *n;
 	unsigned long flags;
 
 	n = kmalloc(sizeof(*n), GFP_ATOMIC);
@@ -175,7 +175,7 @@ static int capiminor_add_ack(struct capiminor *mp, u16 datahandle)
 
 static int capiminor_del_ack(struct capiminor *mp, u16 datahandle)
 {
-	struct datahandle_queue *p, *tmp;
+	struct ackqueue_entry *p, *tmp;
 	unsigned long flags;
 
 	spin_lock_irqsave(&mp->ackqlock, flags);
@@ -194,7 +194,7 @@ static int capiminor_del_ack(struct capiminor *mp, u16 datahandle)
 
 static void capiminor_del_all_ack(struct capiminor *mp)
 {
-	struct datahandle_queue *p, *tmp;
+	struct ackqueue_entry *p, *tmp;
 	unsigned long flags;
 
 	spin_lock_irqsave(&mp->ackqlock, flags);
-- 
1.6.0.2

