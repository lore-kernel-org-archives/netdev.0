From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take5 1/4] kevent: Core files.
Date: Wed, 9 Aug 2006 09:22:11 +0400
Message-ID: <20060809052209.GA17446@2ka.mipt.ru>
References: <11550230871019@2ka.mipt.ru> <44D90A13.4070704@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:32235 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030456AbWHIFWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 01:22:40 -0400
To: Zach Brown <zach.brown@oracle.com>
Content-Disposition: inline
In-Reply-To: <44D90A13.4070704@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 03:02:59PM -0700, Zach Brown (zach.brown@oracle.com) wrote:
> 
> > +++ b/include/linux/kevent.h
> 
>  ...
> 
> > +#ifdef CONFIG_KEVENT_SOCKET
> > +
> > +extern struct file_operations socket_file_ops;
> 
> This doesn't build because socket_file_ops was left static in net/socket.c.

I exported it. It just sneaked out of patchset.

> In any case, kevent.h has no business exposing socket_file_ops to users
> of the kevent api just so the kevent core can test files as being backed
> by sockets.  It'd be more appropriate to call into the socket layer with
> the filp and let it return -EINVAL or -ESOCKNOOPT instead of trying to
> do that in the kevent layer.

Ok, I will move to use some functions from socket code without exporting
socket_file_ops.

> - z

-- 
	Evgeniy Polyakov
