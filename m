From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH] virtio_net: remove double ether_setup
Date: Wed, 12 Dec 2007 08:34:06 +0100
Message-ID: <200712120834.06281.borntraeger@de.ibm.com>
References: <200712111238.53960.borntraeger@de.ibm.com> <200712121241.48226.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.osdl.org, kvm-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:2081 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515AbXLLHeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 02:34:09 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id lBC7Y7Go090974
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 07:34:07 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBC7Y75d3022910
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 08:34:07 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBC7Y6Bf007232
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 08:34:07 +0100
In-Reply-To: <200712121241.48226.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 12. Dezember 2007 schrieb Rusty Russell:
> Can you send straight to akpm or davem?  I'm supposed to be on vacation at 

this is a small fix for virtio_net.
virtnet_probe already calls alloc_etherdev, which calls ether_setup.
There is no need to do that again.

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
Acked-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |    1 -
 1 file changed, 1 deletion(-)

Index: kvm/drivers/net/virtio_net.c
===================================================================
--- kvm.orig/drivers/net/virtio_net.c
+++ kvm/drivers/net/virtio_net.c
@@ -329,11 +329,10 @@ static int virtnet_probe(struct virtio_d
 	dev = alloc_etherdev(sizeof(struct virtnet_info));
 	if (!dev)
 		return -ENOMEM;
 
 	/* Set up network device as normal. */
-	ether_setup(dev);
 	dev->open = virtnet_open;
 	dev->stop = virtnet_close;
 	dev->hard_start_xmit = start_xmit;
 	dev->features = NETIF_F_HIGHDMA;
 	SET_NETDEV_DEV(dev, &vdev->dev);


