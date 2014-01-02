From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [net-next bugfix] tun, rfs:  fix the incorrect hash value
Date: Thu,  2 Jan 2014 13:24:28 +0800
Message-ID: <1388640268-25575-1-git-send-email-zwu.kernel@gmail.com>
Cc: jasowang@redhat.com, therbert@google.com,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:45759 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbaABFYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 00:24:38 -0500
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Wed, 1 Jan 2014 22:24:37 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id D86B31FF001A
	for <netdev@vger.kernel.org>; Wed,  1 Jan 2014 22:24:06 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s025OROD11272628
	for <netdev@vger.kernel.org>; Thu, 2 Jan 2014 06:24:27 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s025OXL3027579
	for <netdev@vger.kernel.org>; Wed, 1 Jan 2014 22:24:33 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

The code incorrectly save the queue index as the hash, so this patch
is fixing it with the hash received in the stack receive path.

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/tun.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3cf0457..09f6662 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -378,8 +378,8 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
 	if (txq) {
 		e = tun_flow_find(&tun->flows[tun_hashfn(txq)], txq);
 		if (e) {
-			txq = e->queue_index;
 			tun_flow_save_rps_rxhash(e, txq);
+			txq = e->queue_index;
 		} else
 			/* use multiply and shift instead of expensive divide */
 			txq = ((u64)txq * numqueues) >> 32;
-- 
1.7.6.5
