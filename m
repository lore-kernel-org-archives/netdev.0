From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 10:21:15 +0200
Message-ID: <1340785275.2028.151.camel@localhost>
References: <201206260734.33472.hans.schillstrom@ericsson.com>
	 <1340730156.10893.359.camel@edumazet-glaptop>
	 <1340778733.2028.110.camel@localhost>
	 <20120626.235423.588696200884989114.davem@davemloft.net>
	 <1340781845.2028.133.camel@localhost>
	 <1340782216.10893.427.camel@edumazet-glaptop>
	 <1340783670.2028.141.camel@localhost>
	 <1340784137.26242.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hans.schillstrom@ericsson.com,
	subramanian.vijay@gmail.com, dave.taht@gmail.com,
	netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	mph@hoth.dk
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23354 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751028Ab2F0IVZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 04:21:25 -0400
In-Reply-To: <1340784137.26242.5.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 10:02 +0200, Eric Dumazet wrote:
> On Wed, 2012-06-27 at 09:54 +0200, Jesper Dangaard Brouer wrote:
> 
> > Well, that would lead to parallel SYN processing, wouldn't it?
> 
> I think we already discussed of the current issues of current code.
> 
> Telling people to spread SYN to several cpus is a good way to have a
> freeze in case of synflood, because 15 cpus are busy looping while one
> is doing progress.

Yes, that was also what I experienced (contention on spinlock), and then
tried to address it with my parallel SYN cookie patches, and it worked
amazing well...


> Thats why Intel felt the need of a hardware filter to direct all SYN
> packets on a single queue.

It works because we have a spinlock problem in the code... Perhaps, they
did it, because we have have locking/contention problem, not the other
way around ;-)  How about fixing the code instead? ;-)))
