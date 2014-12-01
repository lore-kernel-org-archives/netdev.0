From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v8 39/50] tun: add VNET_LE flag
Date: Mon, 1 Dec 2014 18:06:01 +0200
Message-ID: <1417449619-24896-40-git-send-email-mst@redhat.com>
References: <1417449619-24896-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	thuth@linux.vnet.ibm.com, dahi@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-api@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417449619-24896-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

virtio 1.0 modified virtio net header format,
making all fields little endian.

Users can tweak header format before submitting it to tun,
but this means more data copies where none were necessary.
And if the iovec is in RO memory, this means we might
need to split iovec also means we might in theory overflow
iovec max size.

This patch adds a simpler way for applications to handle this,
using new "little endian" flag in tun.
As a result, tun simply byte-swaps header fields as appropriate.
This is a NOP on LE architectures.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/uapi/linux/if_tun.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index 277a260..18b2403 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -57,6 +57,7 @@
 #define IFF_ONE_QUEUE	0x2000
 #define IFF_VNET_HDR	0x4000
 #define IFF_TUN_EXCL	0x8000
+#define IFF_VNET_LE	0x10000
 #define IFF_MULTI_QUEUE 0x0100
 #define IFF_ATTACH_QUEUE 0x0200
 #define IFF_DETACH_QUEUE 0x0400
-- 
MST
