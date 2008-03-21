From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 9/9] ixgb: remove unused variable
Date: Fri, 21 Mar 2008 11:07:08 -0700
Message-ID: <20080321180708.24164.56221.stgit@localhost.localdomain>
References: <20080321180625.24164.46137.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:41394 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754956AbYCUSSX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2008 14:18:23 -0400
In-Reply-To: <20080321180625.24164.46137.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

The variable num_group_tail_writes is initialized but never used otherwise.

The semantic patch that makes this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
type T;
identifier i;
constant C;
@@

(
extern T i;
|
- T i;
  <+... when != i
- i = C;
  ...+>
)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 9c9bf31..c68b182 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -2092,14 +2092,12 @@ ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter)
 	struct ixgb_buffer *buffer_info;
 	struct sk_buff *skb;
 	unsigned int i;
-	int num_group_tail_writes;
 	long cleancount;
 
 	i = rx_ring->next_to_use;
 	buffer_info = &rx_ring->buffer_info[i];
 	cleancount = IXGB_DESC_UNUSED(rx_ring);
 
-	num_group_tail_writes = IXGB_RX_BUFFER_WRITE;
 
 	/* leave three descriptors unused */
 	while(--cleancount > 2) {

