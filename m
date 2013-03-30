From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: fq_codel: Fix off-by-one error
Date: Sat, 30 Mar 2013 08:28:51 -0700
Message-ID: <1364657331.5113.97.camel@edumazet-glaptop>
References: <1364514720-20780-1-git-send-email-subramanian.vijay@gmail.com>
	 <1364569280.5113.21.camel@edumazet-glaptop> <20130330065345.GA23938@x4>
	 <1364654567.5113.85.camel@edumazet-glaptop> <20130330150852.GA11315@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:52290 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755620Ab3C3P2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 11:28:54 -0400
Received: by mail-pb0-f53.google.com with SMTP id un1so603109pbc.26
        for <netdev@vger.kernel.org>; Sat, 30 Mar 2013 08:28:53 -0700 (PDT)
In-Reply-To: <20130330150852.GA11315@x4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-03-30 at 16:08 +0100, Markus Trippelsdorf wrote:

> This is exactly the setup that I'm using right now (prio + 4 fq_codel
> with bittorent set to low).
> And setting the fq_codel limit to 1024 improves latency in this
> situation. 
> That's all I wanted to communicate. If the result doesn't interest you,
> just ignore my mail.
> 

I didn't ignore your mail, I spent time from my Saturday to answer you.

If your prio setting was right, a limit of 10 should be enough for the
high prio queue, and a mere pfifo would be ok.

By definition, high prio packets should have a minimum latency (assuming
of course that BQL is enabled on your device)

Then, if all your packets land into he same prio queue, classification
is not correct.

If your link is oversubscribed (and Bittorent tends to push links to
over subscribed situation), then you want to increase drops by reducing
queue lengths.

fq_codel default limit is only a hint, like all defaults.

Some users want to increase it, others want to decrease it.

In your case, I suspect the number of flows is too large (and you get
hash collisions in fq), _and_ your ping packets land the crowded
fq_codel qdisc, instead of a small queue reserved for high prio packets.
