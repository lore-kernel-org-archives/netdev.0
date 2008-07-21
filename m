From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [crash] kernel BUG at net/core/dev.c:1328!
Date: Mon, 21 Jul 2008 11:35:21 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org>
References: <20080720.104411.81744468.davem@davemloft.net> <20080721133059.GA30637@elte.hu> <20080721134506.GA27598@elte.hu> <20080721182318.GA20940@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37901 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750928AbYGUSgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 14:36:32 -0400
In-Reply-To: <20080721182318.GA20940@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 21 Jul 2008, Ingo Molnar wrote:
>
> [   24.434799] kernel BUG at net/core/dev.c:1328!

Ok, it is now a WARN_ON_ONCE() in my tree (which I _just_ pushed out). 

So it's going to cause irritating messages (once), but the machine should 
hopefully work.

> Should i spend time on bisecting this, or is this known already?

It's going to bisect down to the same commit you already bisected once, 
it's the networking code that changed some of the rules, so various 
network drivers that didn't follow the expected rules are now unhappy.

Maybe the network drivers are few enough that it will get fixed, or maybe 
the WARN_ON_ONCE() will just be removed and the rule not reinforced.

I personally suspect the latter, since it seems to happen with just about 
_any_ random network driver, including the common and well-maintained ones 
(ie the Gods only help us for the truly odd/random cases)

			Linus
