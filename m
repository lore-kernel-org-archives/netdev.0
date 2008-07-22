From: David Newall <davidn@davidnewall.com>
Subject: Re: [TCP bug] stuck distcc connections in latest -git
Date: Tue, 22 Jul 2008 23:15:38 +0930
Message-ID: <4885E482.5020502@davidnewall.com>
References: <20080720.104411.81744468.davem@davemloft.net> <20080721133059.GA30637@elte.hu> <20080721134506.GA27598@elte.hu> <20080721182318.GA20940@elte.hu> <alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org> <20080721184616.GA8442@elte.hu> <20080722112133.GA6575@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth7959.sa.adsl.internode.on.net ([150.101.82.22]:50729 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750975AbYGVNpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 09:45:49 -0400
In-Reply-To: <20080722112133.GA6575@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> hm, the distcc TCP hangs are back:
>   

The missing four client-side connections are more interesting than the
unsent data.

> I.e. the client side send-queue is stuck in established state, server 
> side thinks it's a proper established connection. Nobody makes any 
> progress.
>   

I might be missing something obvious, but I don't think there's anything
unusual in the three sessions displayed on the client.  They should be
"ESTABLISHED", and on the server, too, just as they are.

> Also note the final 4 connections on the server side - those are not 
> present on the client box.
>   

Now this is interesting.  I would be much more interested in how the
client's sides for these disappeared.

> The hung condition seemed permanent (i waited a couple of minutes).
>   

Not nearly long enough.  Retransmits can be sent as infrequently as per
180 seconds.  I think there's an argument to use one of the the various
patches that reduce your TCP_RTO_MAX, for example OBATA Noboru's
(http://marc.info/?l=linux-netdev&m=118422471428855): you don't have to
wait unreasonably long before seeing a retransmit.  Remember, three minutes!


> I retried the same build 10 times and it would not reproduce - so this 
> again is a hard to reproduce condition. (and there's no chance to get a 
> proper tcpdump either, at these traffic levels)

You really should start that capture, and on both client and server. 
You don't need to dump everything, only traffic to or from server:distcc.
