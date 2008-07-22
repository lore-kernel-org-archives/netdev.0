From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP bug] stuck distcc connections in latest -git
Date: Tue, 22 Jul 2008 15:57:23 +0200
Message-ID: <20080722135723.GA23077@elte.hu>
References: <20080720.104411.81744468.davem@davemloft.net> <20080721133059.GA30637@elte.hu> <20080721134506.GA27598@elte.hu> <20080721182318.GA20940@elte.hu> <alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org> <20080721184616.GA8442@elte.hu> <20080722112133.GA6575@elte.hu> <4885E482.5020502@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
To: David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:46661 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711AbYGVN5q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 09:57:46 -0400
Content-Disposition: inline
In-Reply-To: <4885E482.5020502@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Newall <davidn@davidnewall.com> wrote:

> > The hung condition seemed permanent (i waited a couple of minutes).
> 
> Not nearly long enough.  Retransmits can be sent as infrequently as 
> per 180 seconds.  I think there's an argument to use one of the the 
> various patches that reduce your TCP_RTO_MAX, for example OBATA 
> Noboru's (http://marc.info/?l=linux-netdev&m=118422471428855): you 
> don't have to wait unreasonably long before seeing a retransmit.  
> Remember, three minutes!

i know, i waited much more than 180 minutes - about 15 minutes. That is 
more than enough for this LAN connection.

It's all on the LAN directly via a single gigabit switch and no packet 
dropping. I noticed the hung build immediately as it happened.

> > I retried the same build 10 times and it would not reproduce - so 
> > this again is a hard to reproduce condition. (and there's no chance 
> > to get a proper tcpdump either, at these traffic levels)
> 
> You really should start that capture, and on both client and server. 
> You don't need to dump everything, only traffic to or from 
> server:distcc.

It's not feasible. That box did in excess of 200 GB of network traffic 
in the past 7 hours alone. ~10 clients are doing make -j200 type of 
kernel builds to this 16way buildbox so it is not realistic to tcpdump 
it - especially given the rarity of this problem. (it has not reoccured 
since then) The network is local LAN, gigabit ethernet over a single 
gigabit switch.

	Ingo
