From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH] VSOCK: fix uapi/linux/vm_sockets.h incomplete types
Date: Mon, 18 Sep 2017 16:21:00 +0100
Message-ID: <20170918152100.GF4141@stefanha-x1.localdomain>
References: <20170912163435.4049-1-stefanha@redhat.com>
 <20170915.141432.1514866054657107786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhansen@vmware.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55830 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750925AbdISJNG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 05:13:06 -0400
Content-Disposition: inline
In-Reply-To: <20170915.141432.1514866054657107786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 15, 2017 at 02:14:32PM -0700, David Miller wrote:
> > diff --git a/include/uapi/linux/vm_sockets.h b/include/uapi/linux/vm_sockets.h
> > index b4ed5d895699..4ae5c625ac56 100644
> > --- a/include/uapi/linux/vm_sockets.h
> > +++ b/include/uapi/linux/vm_sockets.h
> > @@ -18,6 +18,10 @@
> >  
> >  #include <linux/socket.h>
> >  
> > +#ifndef __KERNEL__
> > +#include <sys/socket.h> /* struct sockaddr */
> > +#endif
> > +
> 
> There is no precedence whatsoever to include sys/socket.h in _any_ UAPI
> header file provided by the kernel.

<linux/if.h> does it for the same reason:

include/uapi/linux/if.h:#include <sys/socket.h>                 /* for struct sockaddr.         */

If that is not acceptable for <linux/vm_sockets.h> then we could do the
same thing as <linux/in.h>:

#define __SOCK_SIZE__   16              /* sizeof(struct sockaddr)      */

Is that okay or do you have another suggestion for getting sizeof(struct
sockaddr)?  It's needed to pad struct sockaddr_vm.

> __kernel_sa_family_t is what should be used in UAPI headers, only
> non-UAPI headers can use plain sa_family_t.
> 
> So that is the correct fix for this problem.

Thanks, will fix in v2.
