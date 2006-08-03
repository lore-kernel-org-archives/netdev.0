From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Thu, 03 Aug 2006 11:32:32 +0200
Message-ID: <44D1C2B0.5050004@trash.net>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <20060802004929.GA12404@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52987 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932433AbWHCJce
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 05:32:34 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060802004929.GA12404@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Mon, Jul 31, 2006 at 09:30:50PM +1000, herbert wrote:
> 
>>>diff --git a/net/ipv4/netfilter/ip_nat_core.c b/net/ipv4/netfilter/ip_nat_core.c
>>>index 1741d55..731efbb 100644
>>>--- a/net/ipv4/netfilter/ip_nat_core.c
>>>+++ b/net/ipv4/netfilter/ip_nat_core.c
>>>@@ -443,7 +443,9 @@ int ip_nat_icmp_reply_translation(struct
>>> 
>>> 	/* We're actually going to mangle it beyond trivial checksum
>>> 	   adjustment, so make sure the current checksum is correct. */
>>>-	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY) {
>>>+
>>>+	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY &&
>>>+	    (*pskb)->ip_summed != CHECKSUM_PARTIAL) {
>>> 		hdrlen = (*pskb)->nh.iph->ihl * 4;
>>> 		if ((u16)csum_fold(skb_checksum(*pskb, hdrlen,
>>> 						(*pskb)->len - hdrlen, 0)))
> 
> 
> Actually, we could drop this chunk of code altogether.
> 
> The reason is that if the packet comes in with the correct checksum,
> it'll go out of NAT with the correct checksum.  If it came in with
> the wrong checksum, it'll go out with the wrong checksum.
> 
> We let TCP packets with incorrect checksums pass through NAT, so why
> not do the same here?
> 
> After all, we're here to do NAT, not verify checksums.  We charge extra
> for that :)

The checksum is verified here because a full checksum update is done
later in that function and we don't want to accidentally fix up
broken checksums.

