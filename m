From: Eran Liberty <liberty@extricom.com>
Subject: Re: [PATCH] gainfar.c : skb_over_panic
Date: Wed, 23 Jun 2010 20:52:38 +0300
Message-ID: <4C2249E6.4030202@extricom.com>
References: <4C1A4E36.5060902@extricom.com>	<20100617.122030.112600189.davem@davemloft.net>	<4C1F2D39.9050804@extricom.com> <20100621.134733.115953029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080900000300020107060408"
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.extricom.com ([212.235.17.194]:50582 "HELO
	smtp.extricom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with SMTP id S1752188Ab0FWRt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 13:49:28 -0400
In-Reply-To: <20100621.134733.115953029.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080900000300020107060408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> At this stage in the code we know exactly what modifications, if any,
> we've made to the SKB state.  Therefore it makes sense to only fix
> up the tiny amount of changes we've made instead of doing a complete
> skb_recycle_call() which seems entirely excessive in this situation.
>
>   
Agreed.

Attached is the corrected patch for the gianfar.c

-- Liberty

--------------080900000300020107060408
Content-Type: text/x-diff;
 name="gianfar_skb_over_panic.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="gianfar_skb_over_panic.patch"

---
 drivers/net/gianfar.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1854,14 +1854,9 @@
 			if (unlikely(!newskb))
 				newskb = skb;
 			else if (skb) {
-				/*
-				 * We need to reset ->data to what it
-				 * was before gfar_new_skb() re-aligned
-				 * it to an RXBUF_ALIGNMENT boundary
-				 * before we put the skb back on the
-				 * recycle list.
-				 */
 				skb->data = skb->head + NET_SKB_PAD;
+				skb->len = 0;
+				skb_reset_tail_pointer(skb);
 				__skb_queue_head(&priv->rx_recycle, skb);
 			}
 		} else {

--------------080900000300020107060408--
