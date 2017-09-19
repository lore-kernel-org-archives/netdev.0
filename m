From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: fix uapi/linux/vm_sockets.h incomplete types
Date: Tue, 19 Sep 2017 10:38:40 -0700 (PDT)
Message-ID: <20170919.103840.379059301652331060.davem@davemloft.net>
References: <20170912163435.4049-1-stefanha@redhat.com>
        <20170915.141432.1514866054657107786.davem@davemloft.net>
        <20170918152100.GF4141@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhansen@vmware.com
To: stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37148 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750973AbdISRil (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:38:41 -0400
In-Reply-To: <20170918152100.GF4141@stefanha-x1.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Mon, 18 Sep 2017 16:21:00 +0100

> On Fri, Sep 15, 2017 at 02:14:32PM -0700, David Miller wrote:
>> > diff --git a/include/uapi/linux/vm_sockets.h b/include/uapi/linux/vm_sockets.h
>> > index b4ed5d895699..4ae5c625ac56 100644
>> > --- a/include/uapi/linux/vm_sockets.h
>> > +++ b/include/uapi/linux/vm_sockets.h
>> > @@ -18,6 +18,10 @@
>> >  
>> >  #include <linux/socket.h>
>> >  
>> > +#ifndef __KERNEL__
>> > +#include <sys/socket.h> /* struct sockaddr */
>> > +#endif
>> > +
>> 
>> There is no precedence whatsoever to include sys/socket.h in _any_ UAPI
>> header file provided by the kernel.
> 
> <linux/if.h> does it for the same reason:
> 
> include/uapi/linux/if.h:#include <sys/socket.h>                 /* for struct sockaddr.         */

You don't need it for struct sockaddr, you need it for sa_family_t,
the comment is very misleading.

Please do as I have instructed and it will fix this problem.

Thank you.
