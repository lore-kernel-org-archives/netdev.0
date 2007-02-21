From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] chelsio: Fix non-NAPI compile
Date: Tue, 20 Feb 2007 23:59:28 -0800
Message-ID: <adamz38c55r.fsf@cisco.com>
References: <20070220235759.102686172@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:44803 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbXBUH7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 02:59:30 -0500
In-Reply-To: <20070220235759.102686172@linux-foundation.org> (Stephen Hemminger's message of "Tue, 20 Feb 2007 15:57:59 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chelsio without NAPI enabled has been broken (won't compile) since
3de00b89 ("chelsio: NAPI speed improvement"):

    drivers/net/chelsio/sge.c: In function `t1_interrupt`:
    drivers/net/chelsio/sge.c:1716: error: `Q` undeclared (first use in this function)

The change below seems to add back in the declaration and
initialization of `Q` that was removed by mistake, and at least makes
the driver compile for me, although I have no hardware and hence no
way to test whether this actually works.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
Hi Stephen, since you seem to be looking after this driver a little
bit (and since you broke it ;), I'll send this patch to you.

If this seems right to you, please merge it (although perhaps it would
make more sense just to kill the non-NAPI code, since no one noticed
it didn't compile).


diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 89a6827..326d4a6 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1696,6 +1696,7 @@ irqreturn_t t1_interrupt(int irq, void *cookie)
 {
 	int work_done;
 	struct adapter *adapter = cookie;
+	struct respQ *Q = &adapter->sge->respQ;
 
 	spin_lock(&adapter->async_lock);
 
