From: Peng Tao <bergwolf@gmail.com>
Subject: [PATCH 2/2] vhost: remove unnecessary smp_mb from vhost_work_queue
Date: Wed,  7 Dec 2016 17:52:19 +0800
Message-ID: <1481104340-77035-2-git-send-email-bergwolf@gmail.com>
References: <1481104340-77035-1-git-send-email-bergwolf@gmail.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, Peng Tao <bergwolf@gmail.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35653 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932110AbcLGJ4F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 04:56:05 -0500
In-Reply-To: <1481104340-77035-1-git-send-email-bergwolf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

test_and_set_bit() already implies a memory barrier.

Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 drivers/vhost/vhost.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c6f2d89..2663543 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -261,8 +261,8 @@ void vhost_work_queue(struct vhost_dev *dev, struct vhost_work *work)
 	if (!test_and_set_bit(VHOST_WORK_QUEUED, &work->flags)) {
 		/* We can only add the work to the list after we're
 		 * sure it was not in the list.
+		 * test_and_set_bit() implies a memory barrier.
 		 */
-		smp_mb();
 		llist_add(&work->node, &dev->work_list);
 		wake_up_process(dev->worker);
 	}
-- 
2.7.4
