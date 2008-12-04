From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH net-2.6] can: omit received RTR frames for single ID filter
 lists
Date: Thu, 04 Dec 2008 18:40:40 +0100
Message-ID: <49381618.8030109@hartkopp.net>
References: <20081128153317.GA3726@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060306080008060106050209"
Cc: Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Linux Netdev List <netdev@vger.kernel.org>, stable@kernel.org
To: David Miller <davem@davemloft.net>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:21884 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760025AbYLDRkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 12:40:47 -0500
In-Reply-To: <20081128153317.GA3726@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060306080008060106050209
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

can: omit received RTR frames for single ID filter lists

Since commit d253eee20195b25e298bf162a6e72f14bf4803e5 the single CAN
identifier filter lists handle only non-RTR CAN frames.

So we need to omit the check of these filter lists when receiving RTR CAN frames.

Signed-Off-by: Oliver Hartkopp <oliver@hartkopp.net>
---

Hello Dave & Greg,

while writing a CAN filter test suite on a business trip i discovered a 
missing check that became necessary together with the referenced commit

'can: Fix CAN_(EFF|RTR)_FLAG handling in can_filter'

Sorry for the effort of this extra patch.

It should go into 2.6.28 before the bug fix window closes.

Additionally the patch applies down to 2.6.26. Greg please consider this patch 
together with the referenced one for stable .26 and .27 also.

Thanks & best regards,
Oliver



--------------060306080008060106050209
Content-Type: text/x-patch;
 name="can_rx_filter.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="can_rx_filter.patch"

diff --git a/net/can/af_can.c b/net/can/af_can.c
index d8173e5..3dadb33 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -622,7 +622,10 @@ static int can_rcv_filter(struct dev_rcv_lists *d, struct sk_buff *skb)
 		}
 	}
 
-	/* check CAN_ID specific entries */
+	/* check filterlists for single non-RTR can_ids */
+	if (can_id & CAN_RTR_FLAG)
+		return matches;
+
 	if (can_id & CAN_EFF_FLAG) {
 		hlist_for_each_entry_rcu(r, n, &d->rx[RX_EFF], list) {
 			if (r->can_id == can_id) {

--------------060306080008060106050209--
