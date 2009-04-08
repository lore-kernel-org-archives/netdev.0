From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix niu warning...
Date: Wed, 08 Apr 2009 15:53:47 -0700 (PDT)
Message-ID: <20090408.155347.60915086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33815
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751745AbZDHWx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 18:53:56 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2522735C4E0
	for <netdev@vger.kernel.org>; Wed,  8 Apr 2009 15:53:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For a while GCC has been emitting driver/net/niu.c:4937
'val' may be use uninitialized in this function

I finally got fed up enough with it to commit the following.

niu: Fix unused variable warning.

Don't strain gcc's tiny mind.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 2cd6109..2b17453 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -4834,6 +4834,7 @@ static int niu_compute_rbr_cfig_b(struct rx_ring_info *rp, u64 *ret)
 {
 	u64 val = 0;
 
+	*ret = 0;
 	switch (rp->rbr_block_size) {
 	case 4 * 1024:
 		val |= (RBR_BLKSIZE_4K << RBR_CFIG_B_BLKSIZE_SHIFT);
-- 
1.6.2.2

