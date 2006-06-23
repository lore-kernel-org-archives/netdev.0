From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH REPOST 1/2] Network Event Notifier Mechanism.
Date: Fri, 23 Jun 2006 15:34:55 -0500
Message-ID: <1151094895.7808.87.camel@stevo-desktop>
References: <20060623201918.32482.89765.stgit@stevo-desktop>
	 <20060623201928.32482.69191.stgit@stevo-desktop>
	 <20060623.132647.39159829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:19732 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1752040AbWFWUe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 16:34:57 -0400
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
> This is so much unnecessary syntactic sugar for what you're
> trying to accomplish.
> 
> Just pass a "void *", and have the type of the object defined by which
> notifier it is.  This is exactly how all notifiers work today.
> 
> Then you don't need any new infrastructure at all.  The existing
> notifier bits handle this kind of scheme already, no need to
> invent new stuff.

Ok.  

But what about the redirect event?  It really needs to pass two bits of
info:  The old dst_entry ptr and the new dst_entry ptr.  This is needed
so the rdma driver can figure out which connections now need to use the
new dst_entry...




