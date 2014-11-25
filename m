From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: fix ring init when there are more TX than RX
 channels
Date: Tue, 25 Nov 2014 15:19:44 -0500 (EST)
Message-ID: <20141125.151944.683290833692724626.davem@davemloft.net>
References: <1416932471-8744-1-git-send-email-cascardo@linux.vnet.ibm.com>
	<20141125.143352.669361329120151757.davem@davemloft.net>
	<20141125195721.GB3933@oc0812247204.br.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, prashant@broadcom.com, mchan@broadcom.com
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38085 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbaKYUTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 15:19:47 -0500
In-Reply-To: <20141125195721.GB3933@oc0812247204.br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: cascardo@linux.vnet.ibm.com
Date: Tue, 25 Nov 2014 17:57:21 -0200

> On Tue, Nov 25, 2014 at 02:33:52PM -0500, David Miller wrote:
>> From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
>> Date: Tue, 25 Nov 2014 14:21:11 -0200
>> 
>> > @@ -8563,7 +8563,8 @@ static int tg3_init_rings(struct tg3 *tp)
>> >  		if (tnapi->rx_rcb)
>> >  			memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
>> >  
>> > -		if (tg3_rx_prodring_alloc(tp, &tnapi->prodring)) {
>> > +		if (tnapi->prodring.rx_std &&
>> > +		    tg3_rx_prodring_alloc(tp, &tnapi->prodring)) {
>> >  			tg3_free_rings(tp);
>> >  			return -ENOMEM;
>> 
>> Maybe a better test is "i < tp->rxq_cnt"?  This is what is used in
>> tg3_mem_rx_acquire() to determine if tg3_rx_prodring_init() happens.
>> 
> 
> Well, what we have in net-next/master does:
> 
> 	for (i = 0; i < limit; i++) {
> 		struct tg3_napi *tnapi = &tp->napi[i];
> 
> 		if (tg3_rx_prodring_init(tp, &tnapi->prodring))
> 			goto err_out;
> 
> where limit is:
> 
> 	limit = tp->rxq_cnt;
> 
> 	if (tg3_flag(tp, ENABLE_RSS))
> 		limit++;
> 
> So, I thought that, instead of rewriting that same logic in
> tg3_init_rings, that we should better just check that the rx_std has
> been allocated, which is going to happen in tg3_rx_prodring_init.
> 
> So, the alternative would be:

Ok, come to think of it, your original test is fine and I've applied
that patch and queued it up for -stable.

Thanks.
