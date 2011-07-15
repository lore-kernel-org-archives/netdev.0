From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] Fix panic in virtnet_remove
Date: Fri, 15 Jul 2011 14:46:50 +0530
Message-ID: <20110715091650.23026.78221.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:59109 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965364Ab1GOJQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 05:16:55 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp07.au.ibm.com (8.14.4/8.13.1) with ESMTP id p6F9Gr8D017861
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 19:16:53 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6F9Grv61187976
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 19:16:53 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6F9GqAF018623
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 19:16:53 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

modprobe -r virtio_net panics in free_netdev() as the
dev is already freed in the newly introduced virtnet_free
(commit 3fa2a1df9094). Since virtnet_remove doesn't require
dev after unregister, I am removing the free_netdev call
in virtnet_remove instead of in virtnet_free (which seems
to be the right place to free the dev). Confirmed that
the panic is fixed with this patch.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/virtio_net.c |    2 --
 1 file changed, 2 deletions(-)

diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
--- org/drivers/net/virtio_net.c	2011-07-04 10:38:33.000000000 +0530
+++ new/drivers/net/virtio_net.c	2011-07-15 14:27:48.000000000 +0530
@@ -1121,8 +1121,6 @@ static void __devexit virtnet_remove(str
 
 	while (vi->pages)
 		__free_pages(get_a_page(vi, GFP_KERNEL), 0);
-
-	free_netdev(vi->dev);
 }
 
 static struct virtio_device_id id_table[] = {
