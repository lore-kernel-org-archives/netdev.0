From: David Miller <davem@davemloft.net>
Subject: Re: [v1 PATCH 0/7] rhashtable: Introduce inlined interface
Date: Fri, 20 Mar 2015 18:17:15 -0400 (EDT)
Message-ID: <20150320.181715.477950273744674777.davem@davemloft.net>
References: <20150320105421.GA18148@gondor.apana.org.au>
	<20150320.161743.1329037804732884094.davem@davemloft.net>
	<20150320212844.GC23301@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, kaber@trash.net,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39235 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbbCTWRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 18:17:17 -0400
In-Reply-To: <20150320212844.GC23301@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 21 Mar 2015 08:28:44 +1100

> On Fri, Mar 20, 2015 at 04:17:43PM -0400, David Miller wrote:
>>
>> Why do you need that trailer[] think in the new netlink code?
>> You only use it in an offsetof() expression and wouldn't sizeof
>> the structure work just fine for that?  This also makes the
>> memset() superfluous in the initializer function.
> 
> Aha I was wating for someone to ask :) Without the trailer it
> gets padded to 16 bytes on x86-64.  I found this out because
> netlink was mysteriously failing due to the extra padding not
> getting zeroed. Designated initializers do not zero padding bytes,
> so you'd need an explicit memset.  Besides, hashing another
> four bytes with jhash that always contained zero seemed wasteful.

Then "offsetof(struct netlink_compare_arg, portid) + sizeof(u32)"?
