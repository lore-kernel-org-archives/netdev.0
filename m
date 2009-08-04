From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
Date: Mon, 03 Aug 2009 20:55:25 -0700 (PDT)
Message-ID: <20090803.205525.156945388.davem@davemloft.net>
References: <OF4A7A6701.1BD183E8-ON65257604.0024A9E1-65257606.0030A90D@in.ibm.com>
	<20090803.202935.221338243.davem@davemloft.net>
	<20090804034910.GA30871@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, kaber@trash.net,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60987
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755098AbZHDDzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 23:55:17 -0400
In-Reply-To: <20090804034910.GA30871@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 4 Aug 2009 11:49:10 +0800

> On Mon, Aug 03, 2009 at 08:29:35PM -0700, David Miller wrote:
>>
>> Although PFIFO is not work-conserving, isn't it important to retain
>> ordering?  What if higher priority packets are in the queue when we
>> enqueue?  This new bypass will send the wrong packet, won't it?
> 
> The bypass only kicks in if the queue length is zero.

Thanks for explaining, makes sense now.

>> I'm beginning to think, if we want to make the default case go as fast
>> as possible, we should just bypass everything altogether.  The entire
>> qdisc layer, all of it.
> 
> Can you be more specific? AFAICS he's already bypassing the qdisc
> layer when it can be done safely.

Ignore this, it's based upon my missing the part where this
bypass only triggers when the qdisc is empty.
