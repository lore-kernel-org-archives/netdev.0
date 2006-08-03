From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Thu, 03 Aug 2006 11:29:41 +0200
Message-ID: <44D1C205.4010509@trash.net>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net> <20060801122916.GA6177@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36603 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932427AbWHCJ3n
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 05:29:43 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060801122916.GA6177@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
>>+u_int16_t nf_proto_csum_update(struct sk_buff *skb,
>>+			       u_int32_t oldval, u_int32_t newval,
>>+			       u_int16_t csum, int pseudohdr)
>>+{
>>+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
>>+		csum = nf_csum_update(oldval, newval, csum);
>>+		if (skb->ip_summed == CHECKSUM_COMPLETE && pseudohdr)
> 
> 
> Shouldn't that be !pseudohdr?

No, if the changed data is part of the pseudo-hdr, we need to update
skb->csum so the skb passes later checksum checks.

>>+			skb->csum = nf_csum_update(oldval, newval, skb->csum);
> 
> 								   ^^^^^^^^^
> 
> This is a 32-bit quantity so nf_csum_update should eat a 32-bit quantity
> as well.  Also, this checksum is not inverted so you need
> 
> 			skb->csum = ~nf_csum_update(oldval, newval, ~skb->csum);

I'll change it to 32-bit and try the inversion, but it works fine this
way.

