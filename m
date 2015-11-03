From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB, HFSC, PIE, FIFO stuck on 2.4Gbit on default values
Date: Tue, 03 Nov 2015 14:02:22 -0800
Message-ID: <1446588142.23275.80.camel@edumazet-glaptop2.roam.corp.google.com>
References: <14bd7629199800f798c8ab932e0285d3@visp.net.lb>
	 <1446577894.23275.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <907cb54c0a27beed12381247ba29bca5@visp.net.lb>
	 <1446580156.23275.74.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56392148.4090309@seti.kr.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Andrew <nitr0@seti.kr.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35372 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964790AbbKCWCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 17:02:24 -0500
Received: by pasz6 with SMTP id z6so30465979pas.2
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 14:02:23 -0800 (PST)
In-Reply-To: <56392148.4090309@seti.kr.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-03 at 23:04 +0200, Andrew wrote:
> Hi.
> 
> This is common trouble due to hierarchical shapers realization (global 
> tree lock on packet dequeuing - so when one CPU looks for parent class 
> where tokens can be borrowed, other CPUs are waiting). It's mentioned 
> even in academic publications :) You can read about it here: 
> http://www.ijcset.com/docs/IJCSET13-04-04-113.pdf
> 
> I think that simple lock removing will greatly improve performance; and 
> race conditions on packets dequeuing shouldn't hurt anything except 
> shaping accuracy. Another solutions looks more complex.

Thanks Andrew, I am very well aware of qdisc spinlock contention.

And race conditions on packets dequeueing will _crash_ your host.
Plainly.

This is why I am advising using GRO in the first place.
