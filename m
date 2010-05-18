From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH] virtio: put last seen used index into ring itself
Date: Tue, 18 May 2010 12:27:19 +0200
Message-ID: <4BF26B87.3080902@redhat.com>
References: <20100518004744.GA21359@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Jiri Pirko <jpirko@redhat.com>, Shirley Ma <xma@us.ibm.com>,
	Amit Shah <amit.shah@redhat.com>,
	Mark McLoughlin <markmc@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, quintela@redhat.com,
	alex.williamson@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100518004744.GA21359@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/18/10 02:47, Michael S. Tsirkin wrote:
> Generally, the Host end of the virtio ring doesn't need to see where
> Guest is up to in consuming the ring.  However, to completely understand
> what's going on from the outside, this information must be exposed.
> For example, host can reduce the number of interrupts by detecting
> that the guest is currently handling previous buffers.
> 
> Fortunately, we have room to expand: the ring is always a whole number
> of pages and there's hundreds of bytes of padding after the avail ring
> and the used ring, whatever the number of descriptors (which must be a
> power of 2).

Hi Michael,

Small build fix for this against Linus upstream.

Jes


Fix build of virtio_net.c

Signed-off-by: Jes.Sorensen@redhat.com
---
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d37e5be..679e2df 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -23,6 +23,7 @@
 #include <linux/module.h>
 #include <linux/virtio.h>
 #include <linux/virtio_net.h>
+#include <linux/virtio_ring.h>
 #include <linux/scatterlist.h>
 #include <linux/if_vlan.h>
 #include <linux/slab.h>
