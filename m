From: David Miller <davem@davemloft.net>
Subject: Re: Linux stack performance drop (TCP and UDP) in 3.10 kernel in
 routed scenario
Date: Wed, 04 Jun 2014 23:08:19 -0700 (PDT)
Message-ID: <20140604.230819.1551847200073068931.davem@davemloft.net>
References: <CAJMXqXaf6P=F4+jLhRFrv9GTRK6K9h5boSgyVCS7e9C31a_YzA@mail.gmail.com>
	<20140604.121819.2149110045488849780.davem@davemloft.net>
	<CAJMXqXZV+tGPi5_d-ndeLYfx-yV6WiyDRBaqMcs0dYNTKfZHrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.ne
To: suprasad.desai@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40649 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbaFEGIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 02:08:20 -0400
In-Reply-To: <CAJMXqXZV+tGPi5_d-ndeLYfx-yV6WiyDRBaqMcs0dYNTKfZHrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suprasad Mutalik Desai <suprasad.desai@gmail.com>
Date: Thu, 5 Jun 2014 07:47:48 +0530

> So, I request you to please suggest on how to address this topic w.r.t
> embedded devices ( routers) which has limited memory resources ?

You are seeing the downside of the tradeoff we have made in removing
the routing cache.

But we are still OK with the ramifications of this tradeoff, these
are the new performance metrics we have to simply live with.

I also think you are quite unreasonable, considering that the real
problem on your setup is the lack of hardware checksum offloading
_PLUS_ the fact that you insist creating a situation where your
"low powered" embedded machine has to checksum every single packet
going through it.  That's rediculous.

Truthfully, you'd also have excellent througput if you didn't have
netfilter, or at least disabled netfilter conntrack checksumming.

That checksum on every packet significantly dwarfs the overhead caused
by the routing lookups.

Therefore, I think you should concentrate your efforts in that area.

So to make it clear, there is nothing we are going to "address" wrt.
routing lookup cost, because we are perfectly happy with the tradeoff
between exploitability, scalability, and performance that we've made.
