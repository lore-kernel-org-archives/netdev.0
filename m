From: Asias He <asias@redhat.com>
Subject: Re: [PATCH 4/4] VSOCK: Fix VSOCK_HASH and VSOCK_CONN_HASH
Date: Fri, 21 Jun 2013 08:22:01 +0800
Message-ID: <20130621002201.GA11759@hj.localdomain>
References: <1371720033-19714-1-git-send-email-asias@redhat.com>
 <1371720033-19714-5-git-send-email-asias@redhat.com>
 <783609149.3265072.1371741133384.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Dmitry Torokhov <dtor@vmware.com>,
	Reilly Grant <grantr@vmware.com>
To: Andy King <acking@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20673 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422687Ab3FUAWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 20:22:06 -0400
Content-Disposition: inline
In-Reply-To: <783609149.3265072.1371741133384.JavaMail.root@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 20, 2013 at 08:12:13AM -0700, Andy King wrote:
> > If we mod with VSOCK_HASH_SIZE -1, we get 0, 1, .... 249.  Actually, we
> > have vsock_bind_table[0 ... 250] and vsock_connected_table[0 .. 250].
> > In this case the last entry will never be used.
> 
> If I remember correctly, we did this on purpose.  There's actually a
> comment about it:
> 
> >   * VSOCK_HASH_SIZE + 1 so that vsock_bind_table[0] through
> >   * vsock_bind_table[VSOCK_HASH_SIZE - 1] are for bound sockets and
> >   * vsock_bind_table[VSOCK_HASH_SIZE] is for unbound sockets.  The hash
> 
> [250] is for unbound sockets.  If you hash on that, you'll mistakenly
> get an unbound socket when looking for a bound one.

We have 

   #define VSOCK_HASH_SIZE         251
   static struct list_head vsock_bind_table[VSOCK_HASH_SIZE + 1];
   #define vsock_bound_sockets(addr) (&vsock_bind_table[VSOCK_HASH(addr)])
   #define vsock_unbound_sockets     (&vsock_bind_table[VSOCK_HASH_SIZE])

So

vsock_bind_table[251 + 1]

[0-250] is for bound sockets, [251] is for unbound sockets, no?

> It is confusing, so perhaps a better way is just to move unbound into
> its own table.

This isn't that confusing, but it would be clearer to have a own unbound table.

> Thanks!
> - Andy

-- 
Asias
