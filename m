From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Mon, 03 May 2010 16:10:58 -0400
Message-ID: <1272917458.3926.8.camel@bigi>
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
Received: from mail-pz0-f204.google.com ([209.85.222.204]:53920 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756045Ab0ECULI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 16:11:08 -0400
Received: by pzk42 with SMTP id 42so344442pzk.4
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 13:11:08 -0700 (PDT)
In-Reply-To: <1272714966.14499.37.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-05-01 at 07:56 -0400, jamal wrote:
> On Sat, 2010-05-01 at 13:42 +0200, Eric Dumazet wrote:
> 
> > But, whole point of epoll is to not change interest each time you get an
> > event.
> > 
> > Without EV_PERSIST, you need two more syscalls per recvfrom()
> > 
> > epoll_wait()
> >  epoll_ctl(REMOVE)
> >  epoll_ctl(ADD)
> >  recvfrom()
> > 
> > Even poll() would be faster in your case
> > 
> > poll(one fd)
> > recvfrom()
> > 
> 
> This is true - but my goal was/is to replicate the regression i was
> seeing[1]. 
> I will try with PERSIST next opportunity. If it gets better
> then it is something that needs documentation in the doc Tom
> promised ;->

I tried it with PERSIST and today's net-next and you are right:
rps was better compared with (99.4% vs 98.1% of 750Kpps).
If however i removed the PERSIST i.e both rps and non-rps
have two extra syscalls, again rps performed worse (93.2% vs 97.8%
of 750Kpps). Eric, I know the answer is not to do the non-PERSIST mode
for rps ;-> But lets just ignore that for a sec:
what the heck is going on? I would expect the degradation to be the same
for both non-rps. 
I also wanna do the broken record reminder that kernels before net-next
of Apr14 were doing about 97% (as opposed to 93% currently for same
test).

cheers,
jamal

