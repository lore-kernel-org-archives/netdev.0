From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net_sched: fix dequeuer fairness
Date: Sun, 26 Jun 2011 12:13:46 -0400
Message-ID: <1309104826.5134.46.camel@mojatatu>
References: <1309097254.5134.24.camel@mojatatu>
	 <1309100994.2532.35.camel@edumazet-laptop>
	 <1309102334.5134.31.camel@mojatatu>
	 <1309103630.2532.42.camel@edumazet-laptop>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:35767 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694Ab1FZQNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 12:13:49 -0400
Received: by iwn6 with SMTP id 6so3527939iwn.19
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2011 09:13:49 -0700 (PDT)
In-Reply-To: <1309103630.2532.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-06-26 at 17:53 +0200, Eric Dumazet wrote:

> 
> This is because of commit 24f8b2385e03a4f.
> 
> Prior to this, we could exit very fast from this function, even after
> receiving a single packet.
> 
> jiffies break is kind of lazy, IMHO ;)

And subjective to the value of Hz. 

In the case of net_rx_action it seems that we need
"something" other than packet budget to get us out of there
in extreme case when we loop and none of the netdevs have anything
to offer. 
In the other extreme it would be very unfair to yield because
of jiffies when budget is not exhausted and devices have something
to offer.

One approach could be to deduct their napi weight when they
return a 0 for work done.

cheers,
jamal

