From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 23/31] CAPI: Rename datahandle_queue -> ackqueue_entry
Date: Fri, 8 Jan 2010 12:39:05 +0100
Message-ID: <97c85bac1af80625e1130b68e4a362a59927b3c1.1264201408.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756272Ab0AVX0m@vger.kernel.org>
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This struct is describing a queue entry, not the queue itself.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index e880639..b8019a1 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -77,7 +77,7 @@ struct capidev;
 struct capincci;
 struct capiminor;
 
-struct datahandle_queue {
+struct ackqueue_entry {
 	struct list_head	list;
 	u16			datahandle;
 };
@@ -156,7 +156,7 @@ static LIST_HEAD(capiminor_list);
 
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
