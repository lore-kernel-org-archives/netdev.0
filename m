From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 11/20] ixgbe: bump PS header size to 512 bytes
Date: Thu, 19 Aug 2010 16:37:21 -0700
Message-ID: <20100819233719.10335.25526.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:42196
	"EHLO qmta09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761Ab0HSXhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:37:45 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Bump the header size for packet split to 512 bytes since this makes the
best use of the 1k buffer that is allocated for any skb 512 bytes or
smaller.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 9e15eb9..7233fef 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -69,15 +69,20 @@
 #define IXGBE_MAX_FCPAUSE		 0xFFFF
 
 /* Supported Rx Buffer Sizes */
-#define IXGBE_RXBUFFER_64    64     /* Used for packet split */
-#define IXGBE_RXBUFFER_128   128    /* Used for packet split */
-#define IXGBE_RXBUFFER_256   256    /* Used for packet split */
+#define IXGBE_RXBUFFER_512   512    /* Used for packet split */
 #define IXGBE_RXBUFFER_2048  2048
 #define IXGBE_RXBUFFER_4096  4096
 #define IXGBE_RXBUFFER_8192  8192
 #define IXGBE_MAX_RXBUFFER   16384  /* largest size for a single descriptor */
 
-#define IXGBE_RX_HDR_SIZE IXGBE_RXBUFFER_256
+/*
+ * NOTE: netdev_alloc_skb reserves up to 64 bytes, NET_IP_ALIGN mans we
+ * reserve 2 more, and skb_shared_info adds an additional 384 bytes more,
+ * this adds up to 512 bytes of extra data meaning the smallest allocation
+ * we could have is 1K.
+ * i.e. RXBUFFER_512 --> size-1024 slab
+ */
+#define IXGBE_RX_HDR_SIZE IXGBE_RXBUFFER_512
 
 #define MAXIMUM_ETHERNET_VLAN_SIZE (ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
 

