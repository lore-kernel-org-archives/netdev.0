From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] vhost: Fix host panic if ioctl called with wrong index
Date: Tue, 25 May 2010 11:10:36 +0530
Message-ID: <20100525054036.2022.66692.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:35307 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756156Ab0EYFnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 01:43:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Missed a boundary value check in vhost_set_vring. The host panics if
idx == nvqs is used in ioctl commands in vhost_virtqueue_init.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/vhost/vhost.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -ruNp org/drivers/vhost/vhost.c new/drivers/vhost/vhost.c
--- org/drivers/vhost/vhost.c	2010-05-24 09:25:57.000000000 +0530
+++ new/drivers/vhost/vhost.c	2010-05-24 09:26:53.000000000 +0530
@@ -374,7 +374,7 @@ static long vhost_set_vring(struct vhost
 	r = get_user(idx, idxp);
 	if (r < 0)
 		return r;
-	if (idx > d->nvqs)
+	if (idx >= d->nvqs)
 		return -ENOBUFS;
 
 	vq = d->vqs + idx;
