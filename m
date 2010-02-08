From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: inet: Remove bogus IGMPv3 report handling
Date: Mon, 8 Feb 2010 14:26:30 +1100
Message-ID: <20100208032630.GA4369@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47648 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750957Ab0BHD0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2010 22:26:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

inet: Remove bogus IGMPv3 report handling

Currently we treat IGMPv3 reports as if it were an IGMPv2/v1 report.
This is broken as IGMPv3 reports are formatted differently.  So we
end up suppressing a bogus multicast group (which should be harmless
as long as the leading reserved field is zero).

In fact, IGMPv3 does not allow membership report suppression so
we should simply ignore IGMPv3 membership reports as a host.

This patch does exactly that.  I kept the case statement for it
so people won't accidentally add it back thinking that we overlooked
this case.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 76c0840..a42f658 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -946,7 +946,6 @@ int igmp_rcv(struct sk_buff *skb)
 		break;
 	case IGMP_HOST_MEMBERSHIP_REPORT:
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
-	case IGMPV3_HOST_MEMBERSHIP_REPORT:
 		/* Is it our report looped back? */
 		if (skb_rtable(skb)->fl.iif == 0)
 			break;
@@ -960,6 +959,7 @@ int igmp_rcv(struct sk_buff *skb)
 		in_dev_put(in_dev);
 		return pim_rcv_v1(skb);
 #endif
+	case IGMPV3_HOST_MEMBERSHIP_REPORT:
 	case IGMP_DVMRP:
 	case IGMP_TRACE:
 	case IGMP_HOST_LEAVE_MESSAGE:

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
