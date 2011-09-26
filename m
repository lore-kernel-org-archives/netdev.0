From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 1/2] virtio-net: Verify page list size before fitting into skb
Date: Mon, 26 Sep 2011 20:41:08 +0300
Message-ID: <1317058869-19276-1-git-send-email-levinsasha928@gmail.com>
Cc: Sasha Levin <levinsasha928@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch verifies that the length of a buffer stored in a linked list
of pages is small enough to fit into a skb.

If the size is larger than a max size of a skb, it means that we shouldn't
go ahead building skbs anyway since we won't be able to send the buffer as
the user requested.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtualization@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Cc: kvm@vger.kernel.org
Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 drivers/net/virtio_net.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0c7321c..64e0717 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -165,6 +165,9 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	unsigned int copy, hdr_len, offset;
 	char *p;
 
+	if (len > MAX_SKB_FRAGS * PAGE_SIZE)
+		return NULL;
+
 	p = page_address(page);
 
 	/* copy small packet so we can reuse these pages for small data */
-- 
1.7.6.1
