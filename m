From: Jeremy Jackson <jerj@coplanar.net>
Subject: Re: netif_stop_queue() and multiple hardware queues
Date: Thu, 06 Jul 2006 10:29:38 -0400
Message-ID: <44AD1E52.8050903@coplanar.net>
References: <43A09D18.9040401@coplanar.net>	<44A88293.7060000@coplanar.net> <20060702.215253.74723494.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bob.coplanar.net ([206.222.78.116]:5030 "EHLO bob.coplanar.net")
	by vger.kernel.org with ESMTP id S1030295AbWGFOaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2006 10:30:12 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060702.215253.74723494.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeremy Jackson <jerj@coplanar.net>
> Date: Sun, 02 Jul 2006 22:36:03 -0400
> 
>> I propose that this is an architecture/framework/API issue that the 
>> Linux core networking code should be dealing with.
> 
> Proposals are worthless if nobody wants to do the work to actually
> implement the proposal.
> 
> Your tone seems to suggest that you feel if you propose something,
> someone will just jump out of their seat and implement your proposal.
> 
> That's not how this works :)

I apologize for the tone.  I *am* interested working on this.  I'm just
surprised nobody has jumped out of their seat to do it :)

I have changed a line or two of kernel code but am by no means an
expert, so I guess I was hoping for some kind of feedback about the
proposal.  I guess submit a patch for discussion?  If it's gross I guess
that would generate some feedback.

What's the best Git tree to base this on?  (maybe it's name means make
svn and and cvs users feel like a stupid git?)

In the current 2.6 network driver interface, the TX path seems to be
based on mydev->hard_start_xmit().  The device driver initiates flow
control with netif_stop_queue().

netif_stop_queue() and other functions (macros in netdevice.h) touch
mydev->state, the bit __LINK_STATE_XOFF:

netif_schedule()
netif_start_queue()
netif_wake_queue()
netif_stop_queue()
netif_queue_stopped()

There is only one queue now, implied by default.  Adding a "hwqueue"
parameter to all of the above would be a start.

It would be ideal if mydev->xmit_lock could be separated out, one for
each hwqueue.  A quick hack to implement this would be for the device to
set the mydev->features NETIF_F_LLTX, and implement per-queue locking.

Teaching qdiscs to use the multiple queues looks tricky in comparison, a 
quick hack might be to have prio's bands map 1:1 with the hardware queues.

Regards,

Jeremy

