From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH, RESEND] chelsio: Fix non-NAPI compile
Date: Mon, 26 Feb 2007 14:58:49 -0800
Message-ID: <ada1wkczfti.fsf_-_@cisco.com>
References: <20070220235759.102686172@linux-foundation.org>
	<adamz38c55r.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:47167 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161301AbXBZW6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 17:58:53 -0500
In-Reply-To: <adamz38c55r.fsf@cisco.com> (Roland Dreier's message of "Tue, 20 Feb 2007 23:59:28 -0800")
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
Jeff, I haven't seen any response from Stephen but Divy from Chelsio
seemed to agree with this patch, so can you please merge it?  Right
now the build is broken with CONFIG_CHELSIO_T1_NAPI=n.

Thanks.


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
 
