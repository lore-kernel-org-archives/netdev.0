From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Fri, 23 Jun 2006 08:17:01 -0500
Message-ID: <1151068621.7808.13.camel@stevo-desktop>
References: <20060621184519.10425.69175.stgit@stevo-desktop>
	 <20060622.015728.59653992.davem@davemloft.net>
	 <1150984380.27156.4.camel@stevo-desktop>
	 <1150990041.3040.6.camel@stevo-desktop>  <1151005381.5392.108.camel@jzny2>
	 <1151008816.3040.60.camel@stevo-desktop>  <1151009762.5392.126.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:10784 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S964819AbWFWNRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 09:17:03 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151009762.5392.126.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-22 at 16:56 -0400, jamal wrote:
> On Thu, 2006-22-06 at 15:40 -0500, Steve Wise wrote:
> > On Thu, 2006-06-22 at 15:43 -0400, jamal wrote:
> > > 
> > > No - what these 2 gents are saying was these events and infrastructure
> > > already exist. 
> > 
> > Notification of the exact events needed does not exist today.   
> > 
> 
> Ok, so you cant event make use of anything that already exists?
> Or is a subset of what you need already there?
> 
> > The key events, again, are:
> > 
> > - the neighbour entry mac address has changed.
> > 
> >
> > - the next hop ip address (ie the neighbour) for a given dst_entry has
> > changed.
> 
> 
> I dont see a difference for the above two from an L2 perspective.
> Are you keeping track of IP addresses?

There is no difference from an L2 perspective, but the RDMA driver needs
notification of each so it can correctly manipulate the L2 table in HW
and/or control block for the affected active connections.

> You didn't answer my question in the previous email as to what RDMA
> needs to keep track of in hardware.
> 

See my previous email.  To reiterate: The HW I'm working on maintains a
L2 table, and each active RDMA connection keeps an index into this
table .  If the mac addr of the next hop changes, then the L2 Table gets
updated.  If the next hop itself changes, then each active connection
must be kicked to update its index into the L2 table.


> > 
> > - the path mtu for a given dst_entry has changed.
> > 
> 
> Same with this.
> 

The RDMA HW needs the path mtu for each connection in order to do
segmentation.



Steve.

