From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] virtio_net: avoid BUG_ON() with large packets when CONFIG_DEBUG_SG=y
Date: Tue, 30 Mar 2010 15:26:35 +1030
Message-ID: <201003301526.35720.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:47677 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754212Ab0C3E4j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 00:56:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AFAICT only weird kvm setups and lguest traverse this code path now.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -351,6 +351,9 @@ static int add_recvbuf_big(struct virtne
 	char *p;
 	int i, err, offset;
 
+	/* This is a waste of cycles, but satisfies CONFIG_DEBUG_SG. */
+	sg_init_table(sg, ARRAY_SIZE(sg));
+
 	/* page in sg[MAX_SKB_FRAGS + 1] is list tail */
 	for (i = MAX_SKB_FRAGS + 1; i > 1; --i) {
 		first = get_a_page(vi, gfp);
