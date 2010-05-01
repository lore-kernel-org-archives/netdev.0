From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Sat, 01 May 2010 09:49:09 -0400
Message-ID: <1272721749.14499.50.camel@bigi>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>
	 <1272547307.2222.83.camel@edumazet-laptop> <1272548258.4258.185.camel@bigi>
	 <1272548980.2222.87.camel@edumazet-laptop> <1272549408.4258.189.camel@bigi>
	 <1272573383.3969.8.camel@bigi>  <1272655814.3879.8.camel@bigi>
	 <1272660000.2230.4.camel@edumazet-laptop>  <1272672394.14499.1.camel@bigi>
	 <1272693424.2230.75.camel@edumazet-laptop> <1272713014.14499.21.camel@bigi>
	 <1272714179.2230.151.camel@edumazet-laptop>
	 <1272714966.14499.37.camel@bigi>
	 <1272720125.2230.178.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:46762 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752188Ab0EANtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 09:49:13 -0400
Received: by vws19 with SMTP id 19so822394vws.19
        for <netdev@vger.kernel.org>; Sat, 01 May 2010 06:49:12 -0700 (PDT)
In-Reply-To: <1272720125.2230.178.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-05-01 at 15:22 +0200, Eric Dumazet wrote:

> You must understand that the whole 'bench' is mostly governed by
> scheduler artifacts. The regression you mention is probably a side
> effect.

likely.

> By slowing down one part, its possible to zap all calls to scheduler and
> go maybe 300% faster (Because consumer threads can avoid 3/4 of the time
> to schedule)
> 
> Reciprocally, optimizing one part of the network stack might make
> threads hitting an empty queue, and need to call more often the
> scheduler.

It is fair to say that what i am seeing is _not_ fatal because it is rps
that is regressing; non-rps is fine. I would consider non-rps to be the
common use scenario and if that was doing badly then it is a problem.
The good news is it is getting better - likely because of some changes
made on behalf of rps ;->
With rps, one could follow some instructions on how to make it better.
I am hoping that some of the system "magic" is documented as Tom
mentioned he will.

> This is why some higly specialized programs never block/schedule and
> perform busy loops instead.

Agreed. My brain cells should learn to accept this fact ;->

cheers,
jamal

