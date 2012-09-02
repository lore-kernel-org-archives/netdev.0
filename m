From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fq_codel: dont reinit flow state
Date: Mon, 03 Sep 2012 01:17:40 +0200
Message-ID: <1346627860.2563.64.camel@edumazet-glaptop>
References: <1346505597.7996.76.camel@edumazet-glaptop>
	 <CAA93jw6mdAaomNfNWt0D4MZYFqXZ3=P+HYe9AEkvwNkAH84GSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:46894 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755173Ab2IBXRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 19:17:46 -0400
Received: by wibhq12 with SMTP id hq12so2848250wib.1
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2012 16:17:45 -0700 (PDT)
In-Reply-To: <CAA93jw6mdAaomNfNWt0D4MZYFqXZ3=P+HYe9AEkvwNkAH84GSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-09-01 at 11:12 -0700, Dave Taht wrote:
> partial NAK.


Kind of weird to NACK a patch you are the author.

It makes both of us plain fools on netdev, dont do that.



> There is no need to reset dropped either, and resetting quantum or not
> is an interesting question.
> 

Yes but totally unrelated to this patch.

It would be good you pollute threads.

Open a new thread, using RFC attribute or something.

> (in both cases they can be initted at init time)
> 
> Lastly, stats->maxpacket is presently a shared resource in fq_codel,
> and the initial setting of 256 was an artifact some test ns2 code
> (according to kathie). In the case of ack traffic owning a queue, this
> can be 64 or 66 bytes (or larger on ipv6 acks).
> 

I really hope you understand how this maxpacket thing is useless ?

In the real life, we dont send only 66 bytes packets.

maxpacket purpose is to relax codel so that it doesnt drop packet if
the qdisc backlog is small (so about to be empty).

Rename this maxpacket to 'relax_codel_under_that_size' if you want to.

> It's totally unclear if this distinction is important in fq_codel at
> present. :/. Obviously in codel which is a pure FIFO, maxpacket will
> hit the max size really fast.
> 
> A related problem on maxpacket is if someone turns off tso/gso/ufo, it
> remains set to the largest packet seen forever until the qdisc is
> re-initialized.
> This leads to really puzzling behavior... (I'll submit a patch for
> this shortly but not change fq_codel's
> centralized stats)
> 
> I'd be happy (for now) if dropped was preserved,
> and to fiddle with the other ideas a while longer.
> 

There is no dropped field, what are you talking about ?

If you are now unsure of the patch, I can repost the same patch but
as the author.

Its a real obvious one. After an idle period, CODEL needs to compute the
delay between now and previous 'drop_next'

Codel doesnt call codel_vars_init() but in the qdisc init.

fq_codel being FQ + CODEL, it is an error to call codel_vars_init()
outside of init path.
