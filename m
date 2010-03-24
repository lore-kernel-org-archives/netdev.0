From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/3] ixgbevf: Fix signed/unsigned int error
Date: Wed, 24 Mar 2010 12:35:42 -0700
Message-ID: <20100324193515.6078.27035.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:50914 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750710Ab0CXTgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 15:36:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

In the Tx mapping function if a DMA error occurred then the unwind of
previously mapped sections would improperly check an unsigned int if
it was less than zero.  Changed the index variable to signed to avoid
the error.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/ixgbevf_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 9aaebd3..55f74b3 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -2921,9 +2921,10 @@ static int ixgbevf_tx_map(struct ixgbevf_adapter *adapter,
 	struct ixgbevf_tx_buffer *tx_buffer_info;
 	unsigned int len;
 	unsigned int total = skb->len;
-	unsigned int offset = 0, size, count = 0, i;
+	unsigned int offset = 0, size, count = 0;
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int f;
+	int i;
 
 	i = tx_ring->next_to_use;
 

