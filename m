From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Thu, 22 Jun 2006 16:36:37 -0400
Message-ID: <1151008597.5392.118.camel@jzny2>
References: <20060621184519.10425.69175.stgit@stevo-desktop>
	 <20060622.015728.59653992.davem@davemloft.net>
	 <1150984380.27156.4.camel@stevo-desktop>
	 <1150990041.3040.6.camel@stevo-desktop>  <1151005381.5392.108.camel@jzny2>
	 <1151007524.3040.48.camel@stevo-desktop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:36260 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1161333AbWFVUgj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 16:36:39 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FtVut-0002Mg-Hh
	for netdev@vger.kernel.org; Thu, 22 Jun 2006 16:36:43 -0400
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <1151007524.3040.48.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-22-06 at 15:18 -0500, Steve Wise wrote:
> On Thu, 2006-06-22 at 15:43 -0400, jamal wrote:

> > As an example, search for NETDEV_CHANGEADDR,NETDEV_CHANGEMTU etc.
> > Actually you are probably making this too complicated. 
> 
> NETDEV_CHANGEADDR uses a notifier block, and the network subsystem calls
> call_netdevice_notifiers() when it sets an addr.  And any kernel module
> can register for these events.  That's the model I used to create the
> netevent_notifier mechanism in the patch I posted.
> 

it also gets emmited as a netlink event.

> I could add the new events to this netdevice notifier, but these aren't
> really net device events.  Their network events.  
> 

Different blocks for sure - the point is the infrastructure which
constitutes using notifiers exists. And it is joined at the hip with
netlink.


> I can indeed extend the rtnetlink stuff to add the events in question
> (neighbour mac addr change, route redirect, etc). In fact, there is
> similar functionality under the CONFIG_ARPD option to support a user
> space arp daemon.  Its not quite the same, and it doesn't cover redirect
> and routing events, just neighbour events.
> 

CONFIG_ARPD will give you all neighbor events you need. 
=> rt_redirect doesnt exist neither do route cache
creation/updates/deletions. FIB changes exist etc

> But in the case of the RDMA subsystem, the consumer of these events is
> in the kernel.  Why is it better to propagate events all the way up to
> user space, then send the event back down into the Infiniband kernel
> subsystem?  That seems very inefficient.  

Your mileage may vary. If you do it in user space you dont have to wait
for the next kernel release in case of a bug. Additionally, it allows
for more feature richness that would tend to bloat the kernel/infiniband
otherwise. 

Out of curiosity - what does RDMA NIC have that would need these events?
a route table or L2 table etc? Can you elucidate a little?

cheers,
jamal

