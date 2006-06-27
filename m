From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH Round 2 0/2][RFC] Network Event Notifier Mechanism
Date: Tue, 27 Jun 2006 15:33:19 -0500
Message-ID: <1151440399.20252.9.camel@stevo-desktop>
References: <1151420539.3207.29.camel@stevo-desktop>
	 <20060627.131443.104035750.davem@davemloft.net>
	 <1151439548.20252.2.camel@stevo-desktop>
	 <20060627.132132.21596632.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:47108 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1161292AbWF0UdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 16:33:20 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060627.132132.21596632.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-06-27 at 13:21 -0700, David Miller wrote:
> From: Steve Wise <swise@opengridcomputing.com>
> Date: Tue, 27 Jun 2006 15:19:08 -0500
> 
> > For an RDMA NIC, all this logic is in HW, which is why we need the event
> > notification; to tell the HW to change its next hop information.
> 
> Back to the route change notification, I still think you can
> get what you need by just looking for the route delete.
> 
> You can match if any RDMA connection is using the deleted
> route, mark it "update pending" or something like that,
> and when the you get the "new route" event you can walk the
> "pending" list and try to relookup the route for those
> connections.

>From my experimentation with netlink, RTM_NEWROUTE and RTM_DELROUTE
messages do not get sent up for redirect events.  I have, in fact, added
this with the new patch I'll send out soon.  So either way I need to
change the IPv[46] code to generate a notification for redirects.  With
the single NETEVENT_REDIRECT call, the RDMA driver can, in one sweep,
update all the connections.  It seems more efficient.  At the place
where I've hooked redirect, both the old route and the new route are
already created.


Steve.

