From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH REPOST 1/2] Network Event Notifier Mechanism.
Date: Mon, 26 Jun 2006 10:26:11 -0500
Message-ID: <1151335571.2398.37.camel@stevo-desktop>
References: <20060623201918.32482.89765.stgit@stevo-desktop>
	 <20060623201928.32482.69191.stgit@stevo-desktop>
	 <20060623.132647.39159829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:100 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1751035AbWFZP0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 11:26:13 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060623.132647.39159829.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-06-23 at 13:26 -0700, David Miller wrote:
> From: Steve Wise <swise@opengridcomputing.com>
> Date: Fri, 23 Jun 2006 15:19:28 -0500
> 
> > +struct netevent_route_change {
> > +        int event;
> > +        struct fib_info *fib_info;
> > +};
> 
> It's not generic if you're putting ipv4 FIB route objects
> in the datastructure.
> 

True. 

I guess what I think we should do is pass the fib_info * when its a IPv4
route add/del, and a rt6_info * when its a IPv6 add/del.  This avoids
having to create some new family independent struct.  What I'll have to
do, however, is have specific notifier event enums for each: 

NETEVENT_IPV4_ROUTE_ADD
NETEVENT_IPV4_ROUTE_DEL
NETEVENT_IPV6_ROUTE_ADD
NETEVENT_IPV6_ROUTE_DEL

This keeps it simple IMO...

Does that sound reasonable to you?

Steve.




