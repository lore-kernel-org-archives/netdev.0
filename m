From: David Miller <davem@davemloft.net>
Subject: Re: kernel BUG at net/core/skbuff.c in linux-2.6.21-rc6
Date: Sat, 14 Apr 2007 10:04:41 -0700 (PDT)
Message-ID: <20070414.100441.15000708.davem@davemloft.net>
References: <461DC70B.4000500@trash.net>
	<20070413.161635.26523891.davem@davemloft.net>
	<17953.1560.855914.274514@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, poemann@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57178
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753008AbXDNREu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2007 13:04:50 -0400
In-Reply-To: <17953.1560.855914.274514@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Mackerras <paulus@samba.org>
Date: Sun, 15 Apr 2007 02:49:28 +1000

> I didn't see the patch (the message that this is a reply to is the
> first one that I have seen in this thread), so I can't comment on it.

Here is Patrick McHardy's patch:

diff --git a/drivers/net/ppp_async.c b/drivers/net/ppp_async.c
index 933e2f3..c68e37f 100644
--- a/drivers/net/ppp_async.c
+++ b/drivers/net/ppp_async.c
@@ -890,6 +890,8 @@ ppp_async_input(struct asyncppp *ap, const unsigned char *buf,
  				ap->rpkt = skb;
  			}
  			if (skb->len == 0) {
+				int headroom = 0;
+
  				/* Try to get the payload 4-byte aligned.
  				 * This should match the
  				 * PPP_ALLSTATIONS/PPP_UI/compressed tests in
@@ -897,7 +899,10 @@ ppp_async_input(struct asyncppp *ap, const unsigned char *buf,
  				 * enough chars here to test buf[1] and buf[2].
  				 */
 				if (buf[0] != PPP_ALLSTATIONS)
-					skb_reserve(skb, 2 + (buf[0] & 1));
+					headroom += 2;
+				if (buf[0] & 1)
+					headroom += 1;
+				skb_reserve(skb, headroom);
 			}
 			if (n > skb_tailroom(skb)) {
 				/* packet overflowed MRU */
