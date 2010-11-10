From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socketfilters
Date: Wed, 10 Nov 2010 23:25:08 +0900
Message-ID: <201011102325.JAF82308.OSVLFHtFJMQFOO@I-love.SAKURA.ne.jp>
References: <1289341724.7380.13.camel@dan>
	<20101109.212838.193698340.davem@davemloft.net>
	<1289368423.2700.17.camel@edumazet-laptop>
	<1289373771.2700.110.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:52049 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755816Ab0KJOZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Nov 2010 09:25:12 -0500
In-Reply-To: <1289373771.2700.110.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just I thought...

> unsigned int sk_run_filter(struct sk_buff *skb, struct sock_filter *filter, int flen)
> {
> 	struct sock_filter *fentry;     /* We walk down these */
Can't this be "const struct sock_filter *"?
> (...snipped...)
> 	for (pc = 0; pc < flen; pc++) {
> 		fentry = &filter[pc];
Can't we do
		u32 f_k = fentry->k;
and replace 27 repetition of fentry->k with f_k?
