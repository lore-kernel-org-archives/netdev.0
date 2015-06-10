From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 linux-next] vxge: use swap() in vxge_hw_channel_dtr_alloc()
Date: Wed, 10 Jun 2015 18:33:26 +0200
Message-ID: <1433954006-24799-1-git-send-email-fabf@skynet.be>
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	Fabian Frederick <fabf@skynet.be>,
	Jon Mason <jdmason@kudzu.us>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use kernel.h macro definition.

Thanks to Julia Lawall for Coccinelle scripting support.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/neterion/vxge/vxge-traffic.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-traffic.c b/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
index 9e1aaa7..5f630a2 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
@@ -1004,8 +1004,6 @@ void vxge_hw_device_clear_tx_rx(struct __vxge_hw_device *hldev)
 static enum vxge_hw_status
 vxge_hw_channel_dtr_alloc(struct __vxge_hw_channel *channel, void **dtrh)
 {
-	void **tmp_arr;
-
 	if (channel->reserve_ptr - channel->reserve_top > 0) {
 _alloc_after_swap:
 		*dtrh =	channel->reserve_arr[--channel->reserve_ptr];
@@ -1020,10 +1018,7 @@ _alloc_after_swap:
 	 * i.e.	no additional lock need	to be done when	we free	a resource */
 
 	if (channel->length - channel->free_ptr > 0) {
-
-		tmp_arr	= channel->reserve_arr;
-		channel->reserve_arr = channel->free_arr;
-		channel->free_arr = tmp_arr;
+		swap(channel->reserve_arr, channel->free_arr);
 		channel->reserve_ptr = channel->length;
 		channel->reserve_top = channel->free_ptr;
 		channel->free_ptr = channel->length;
-- 
2.4.2
