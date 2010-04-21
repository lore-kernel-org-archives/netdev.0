From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: add a missing ntohs()
Date: Tue, 20 Apr 2010 18:21:36 -0700 (PDT)
Message-ID: <20100420.182136.67592677.davem@davemloft.net>
References: <1271769605.7895.14.camel@edumazet-laptop>
	<20100420133016.GA21788@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48670
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754250Ab0DUBVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 21:21:31 -0400
In-Reply-To: <20100420133016.GA21788@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 20 Apr 2010 21:30:16 +0800

> On Tue, Apr 20, 2010 at 03:20:05PM +0200, Eric Dumazet wrote:
>> Found by code review and sparse endianness warning, I am not sure this
>> patch is valid.
>> 
>> Thanks
>> 
>> [PATCH] bridge: add a missing ntohs()
>> 
>> grec_nsrcs is in network order, we should convert to host horder in
>> br_multicast_igmp3_report()
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Good catch Eric.

Note that this means that most igmpv3_grec entries get ignored
on little-endian because the greg_nsrcs will look "real big"
and thus the pskb_may_pull() will fail.

Anyways I'll apply this to net-2.6, thanks.
