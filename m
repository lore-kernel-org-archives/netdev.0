From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 11:23:34 +0200
Message-ID: <1340789014.2028.165.camel@localhost>
References: <201206260734.33472.hans.schillstrom@ericsson.com>
	 <1340730156.10893.359.camel@edumazet-glaptop>
	 <1340778733.2028.110.camel@localhost>
	 <20120626.235423.588696200884989114.davem@davemloft.net>
	 <1340781845.2028.133.camel@localhost>
	 <1340782216.10893.427.camel@edumazet-glaptop>
	 <1340783670.2028.141.camel@localhost>
	 <1340784137.26242.5.camel@edumazet-glaptop>
	 <1340785275.2028.151.camel@localhost>
	 <1340786710.26242.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hans.schillstrom@ericsson.com,
	subramanian.vijay@gmail.com, dave.taht@gmail.com,
	netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	mph@hoth.dk
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34563 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884Ab2F0JXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 05:23:43 -0400
In-Reply-To: <1340786710.26242.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 10:45 +0200, Eric Dumazet wrote:
> On Wed, 2012-06-27 at 10:21 +0200, Jesper Dangaard Brouer wrote:
> 
> > It works because we have a spinlock problem in the code... Perhaps, they
> > did it, because we have have locking/contention problem, not the other
> > way around ;-)  How about fixing the code instead? ;-)))
> 
> The socket lock is currently mandatory.
>
> It's really _hard_ to remove it, your attempts added a lot of races.

Yes, its really hard to remove completely.  That's why I choose _only_
to handle the SYN cookie "overload" case, and leave the rest locked, and
I also introduced extra locking in the latest patches.  I know it was
not perfect, hence the RFC tag, but I hope I didn't add that many races.


> I want to do it properly, adding needed RCU and array of spinlocks were
> appropriate.

I really appreciate that you will attempt to fix this properly.  Like a
real network ninja ;-).
