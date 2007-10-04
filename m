From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix kernel_accept() error path
Date: Thu, 04 Oct 2007 15:08:37 -0700 (PDT)
Message-ID: <20071004.150837.102125151.davem@davemloft.net>
References: <47054AF5.4050409@cybernetics.com>
	<Xine.LNX.4.64.0710041456300.13076@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tonyb@cybernetics.com, netdev@vger.kernel.org
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54960
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753345AbXJDWIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 18:08:38 -0400
In-Reply-To: <Xine.LNX.4.64.0710041456300.13076@us.intercode.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Thu, 4 Oct 2007 14:57:33 -0700 (PDT)

> On Thu, 4 Oct 2007, Tony Battersby wrote:
> 
> > If accept() returns an error, kernel_accept() releases the new socket
> > but passes a pointer to the released socket back to the caller.  Make it
> > pass back NULL instead.
> > 
> > Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
> > ---
> > --- linux-2.6.23-rc9/net/socket.c.bak	2007-10-04 15:21:17.000000000 -0400
> > +++ linux-2.6.23-rc9/net/socket.c	2007-10-04 15:21:22.000000000 -0400
> > @@ -2230,6 +2230,7 @@ int kernel_accept(struct socket *sock, s
> >  	err = sock->ops->accept(sock, *newsock, flags);
> >  	if (err < 0) {
> >  		sock_release(*newsock);
> > +		*newsock = NULL;
> >  		goto done;
> >  	}
> >  
> 
> If you get an error back from kernel_accept, you should not be trying to 
> use newsock.

Agreed, the caller should not try to deref the thing, it's
value is undefined.
