From: akpm@linux-foundation.org
Subject: [patch 7/8] hci_usb: replace mb with smp_mb
Date: Mon, 22 Sep 2008 14:50:42 -0700
Message-ID: <200809222150.m8MLog27031875@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	tom.leiming@gmail.com, hidave.darkstar@gmail.com,
	marcel@holtmann.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58971 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753919AbYIVV5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:57:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ming Lei <tom.leiming@gmail.com>

smp_mb is enough for ordering memory operations among processors,and mb is
more expensive than smp_mb for UP machine, so replace it with smp_mb().

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
Acked-by: Marcel Holtmann <marcel@holtmann.org>
Cc: Dave Young <hidave.darkstar@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/bluetooth/hci_usb.h |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff -puN drivers/bluetooth/hci_usb.h~hci_usb-replace-mb-with-smp_mb drivers/bluetooth/hci_usb.h
--- a/drivers/bluetooth/hci_usb.h~hci_usb-replace-mb-with-smp_mb
+++ a/drivers/bluetooth/hci_usb.h
@@ -70,8 +70,8 @@ static inline void _urb_queue_head(struc
 {
 	unsigned long flags;
 	spin_lock_irqsave(&q->lock, flags);
-	/* _urb_unlink needs to know which spinlock to use, thus mb(). */
-	_urb->queue = q; mb(); list_add(&_urb->list, &q->head);
+	/* _urb_unlink needs to know which spinlock to use, thus smp_mb(). */
+	_urb->queue = q; smp_mb(); list_add(&_urb->list, &q->head);
 	spin_unlock_irqrestore(&q->lock, flags);
 }
 
@@ -79,8 +79,8 @@ static inline void _urb_queue_tail(struc
 {
 	unsigned long flags;
 	spin_lock_irqsave(&q->lock, flags);
-	/* _urb_unlink needs to know which spinlock to use, thus mb(). */
-	_urb->queue = q; mb(); list_add_tail(&_urb->list, &q->head);
+	/* _urb_unlink needs to know which spinlock to use, thus smp_mb(). */
+	_urb->queue = q; smp_mb(); list_add_tail(&_urb->list, &q->head);
 	spin_unlock_irqrestore(&q->lock, flags);
 }
 
@@ -89,7 +89,7 @@ static inline void _urb_unlink(struct _u
 	struct _urb_queue *q;
 	unsigned long flags;
 
-	mb();
+	smp_mb();
 	q = _urb->queue;
 	/* If q is NULL, it will die at easy-to-debug NULL pointer dereference.
 	   No need to BUG(). */
_
