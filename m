From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Thu, 22 Jun 2006 15:18:44 -0500
Message-ID: <1151007524.3040.48.camel@stevo-desktop>
References: <20060621184519.10425.69175.stgit@stevo-desktop>
	 <20060622.015728.59653992.davem@davemloft.net>
	 <1150984380.27156.4.camel@stevo-desktop>
	 <1150990041.3040.6.camel@stevo-desktop>  <1151005381.5392.108.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:22842 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1030384AbWFVUSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 16:18:46 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151005381.5392.108.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-22 at 15:43 -0400, jamal wrote:
> On Thu, 2006-22-06 at 10:27 -0500, Steve Wise wrote:
> 
> > 
> > The in-kernel Infiniband subsystem needs to know when certain events
> > happen.  For example, if the mac address of a neighbour changes.  Any
> > rdma devices that are using said neighbour need to be notified of the
> > change.  You are asking that I extend the netlink facility (if
> > necessary) to provide this functionality.  
> > 
> 
> No - what these 2 gents are saying was these events and infrastructure
> already exist. If there are some events that dont and you need to extend
> what already exists. Your patch was a serious reinvention of the wheel
> (and in the case of the neighbor code looking very wrong).

ok.

> As an example, search for NETDEV_CHANGEADDR,NETDEV_CHANGEMTU etc.
> Actually you are probably making this too complicated. 

NETDEV_CHANGEADDR uses a notifier block, and the network subsystem calls
call_netdevice_notifiers() when it sets an addr.  And any kernel module
can register for these events.  That's the model I used to create the
netevent_notifier mechanism in the patch I posted.

I could add the new events to this netdevice notifier, but these aren't
really net device events.  Their network events.  

> Listen to events
> in user space and tell infiniband from user space.
> 

I can indeed extend the rtnetlink stuff to add the events in question
(neighbour mac addr change, route redirect, etc). In fact, there is
similar functionality under the CONFIG_ARPD option to support a user
space arp daemon.  Its not quite the same, and it doesn't cover redirect
and routing events, just neighbour events.

But in the case of the RDMA subsystem, the consumer of these events is
in the kernel.  Why is it better to propagate events all the way up to
user space, then send the event back down into the Infiniband kernel
subsystem?  That seems very inefficient.  

Steve.

