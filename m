From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 15/18] virtio_net: delay TX callbacks
Date: Wed, 4 May 2011 23:52:42 +0300
Message-ID: <48ddc1561adc0ce8f26e26ecb326a5c504a74e7e.1304541919.git.mst@redhat.com>
References: <cover.1304541918.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Carsten Otte <cotte@de.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	linux390@de.ibm.com, Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Shirley Ma <xma@us.ibm.com>, lguest@lists.ozlabs.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, kvm@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>, steved@us.ibm.com,
	habanero@linux.vnet.ibm.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13924 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755867Ab1EDUxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 16:53:22 -0400
Content-Disposition: inline
In-Reply-To: <cover.1304541918.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ask for delayed callbacks on TX ring full, to give the
other side more of a chance to make progress.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0cb0b06..f685324 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -609,7 +609,7 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * before it gets out of hand.  Naturally, this wastes entries. */
 	if (capacity < 2+MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
-		if (unlikely(!virtqueue_enable_cb(vi->svq))) {
+		if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
 			/* More just got used, free them then recheck. */
 			capacity += free_old_xmit_skbs(vi);
 			if (capacity >= 2+MAX_SKB_FRAGS) {
-- 
1.7.5.53.gc233e

