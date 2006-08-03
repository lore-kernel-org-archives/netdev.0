From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Thu, 03 Aug 2006 11:43:14 +0200
Message-ID: <44D1C532.8000708@trash.net>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <20060802004929.GA12404@gondor.apana.org.au> <44D1C2B0.5050004@trash.net> <20060803093623.GC8808@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:25596 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932450AbWHCJnQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 05:43:16 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060803093623.GC8808@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Aug 03, 2006 at 11:32:32AM +0200, Patrick McHardy wrote:
> 
>>The checksum is verified here because a full checksum update is done
>>later in that function and we don't want to accidentally fix up
>>broken checksums.
> 
> 
> Sorry, I missed that.
> 
> BTW, we should make sure that we clear CHECKSUM_COMPLETE since at the
> end of the function skb->csum no longer contains the payload checksum.

nf_ip_checksum sets skb->ip_summed to CHECKSUM_UNNECESSARY in case
the checksum was correct. If not the packet is dropped, so I think
it should be fine.
