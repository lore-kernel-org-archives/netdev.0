From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 2/2] virtio-net: Prevent NULL dereference
Date: Mon, 26 Sep 2011 20:41:09 +0300
Message-ID: <1317058869-19276-2-git-send-email-levinsasha928@gmail.com>
References: <1317058869-19276-1-git-send-email-levinsasha928@gmail.com>
Cc: Sasha Levin <levinsasha928@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:35093 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990Ab1IZRme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 13:42:34 -0400
In-Reply-To: <1317058869-19276-1-git-send-email-levinsasha928@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prevents a NULL dereference when the user has passed a length
longer than an actual buffer to virtio-net.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtualization@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Cc: kvm@vger.kernel.org
Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 drivers/net/virtio_net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 64e0717..8d32c1e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -198,7 +198,7 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	len -= copy;
 	offset += copy;
 
-	while (len) {
+	while (len && page) {
 		set_skb_frag(skb, page, offset, &len);
 		page = (struct page *)page->private;
 		offset = 0;
-- 
1.7.6.1
