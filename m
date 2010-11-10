From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socketfilters
Date: Wed, 10 Nov 2010 10:32:34 -0800 (PST)
Message-ID: <20101110.103234.183039029.davem@davemloft.net>
References: <1289368423.2700.17.camel@edumazet-laptop>
	<1289373771.2700.110.camel@edumazet-laptop>
	<201011102325.JAF82308.OSVLFHtFJMQFOO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54367
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754069Ab0KJScJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 13:32:09 -0500
In-Reply-To: <201011102325.JAF82308.OSVLFHtFJMQFOO@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 10 Nov 2010 23:25:08 +0900

> Just I thought...
> 
>> unsigned int sk_run_filter(struct sk_buff *skb, struct sock_filter *filter, int flen)
>> {
>> 	struct sock_filter *fentry;     /* We walk down these */
> Can't this be "const struct sock_filter *"?
>> (...snipped...)
>> 	for (pc = 0; pc < flen; pc++) {
>> 		fentry = &filter[pc];
> Can't we do
> 		u32 f_k = fentry->k;
> and replace 27 repetition of fentry->k with f_k?

Yes, this feedback seems reasonable, I'll make these changes when I
apply Eric's patch, thanks!
