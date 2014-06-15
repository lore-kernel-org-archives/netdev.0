From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH -next 14/26] rt2x00: Use dma_zalloc_coherent
Date: Sun, 15 Jun 2014 13:37:43 -0700
Message-ID: <cbc917d6b5c2682ad90ca712eae7da9c041ab1af.1402863905.git.joe@perches.com>
References: <cover.1402863904.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
In-Reply-To: <cover.1402863904.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <http://rt2x00.serialmonkey.com/mailman/options/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=unsubscribe>
List-Archive: <http://rt2x00.serialmonkey.com/pipermail/users_rt2x00.serialmonkey.com/>
List-Post: <mailto:users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
List-Help: <mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=help>
List-Subscribe: <http://rt2x00.serialmonkey.com/mailman/listinfo/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=subscribe>
Errors-To: users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
Sender: "users" <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
List-Id: netdev.vger.kernel.org

Use the zeroing function instead of dma_alloc_coherent & memset(,0,)

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/rt2x00/rt2x00mmio.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00mmio.c b/drivers/net/wireless/rt2x00/rt2x00mmio.c
index 6f236ea..f0178fd 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mmio.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mmio.c
@@ -119,14 +119,12 @@ static int rt2x00mmio_alloc_queue_dma(struct rt2x00_dev *rt2x00dev,
 	/*
 	 * Allocate DMA memory for descriptor and buffer.
 	 */
-	addr = dma_alloc_coherent(rt2x00dev->dev,
-				  queue->limit * queue->desc_size,
-				  &dma, GFP_KERNEL);
+	addr = dma_zalloc_coherent(rt2x00dev->dev,
+				   queue->limit * queue->desc_size, &dma,
+				   GFP_KERNEL);
 	if (!addr)
 		return -ENOMEM;
 
-	memset(addr, 0, queue->limit * queue->desc_size);
-
 	/*
 	 * Initialize all queue entries to contain valid addresses.
 	 */
-- 
1.8.1.2.459.gbcd45b4.dirty
