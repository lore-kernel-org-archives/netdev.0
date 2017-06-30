From: Mike Galbraith <efault@gmx.de>
Subject: Re: kernel (master) build failure w. !CONFIG_NET_RX_BUSY_POLL
Date: Fri, 30 Jun 2017 04:18:17 +0200
Message-ID: <1498789097.28164.33.camel@gmx.de>
References: <1498636860.5505.28.camel@gmx.de>
         <20170629.153527.1327069677943074079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-rt-users@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:55059 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751560AbdF3CS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 22:18:26 -0400
In-Reply-To: <20170629.153527.1327069677943074079.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-29 at 15:35 -0400, David Miller wrote:
> From: Mike Galbraith <efault@gmx.de>
> Date: Wed, 28 Jun 2017 10:01:00 +0200
> 
> > Greetings network wizards,
> > 
> > The latest RT explicitly disables CONFIG_NET_RX_BUSY_POLL, thus
> > uncovering $subject.  Below is what I did about it.
> > 
> >       -Mike
> > 
> > net: Move napi_hash_add/del() inside CONFIG_NET_RX_BUSY_POLL
> > 
> > Since 545cd5e5ec54 ("net: Busy polling should ignore sender CPUs"),
> > kernel build fails when CONFIG_NET_RX_BUSY_POLL is disabled.  Move
> > napi_hash_add/del() accordingly.
> > 
> > Banged-upon-by: Mike Galbraith <efault@gmx.de>
> 
> First, this is in no way a standard signoff or ack tag.

It's not intended to be, it's intended to stress that this in not a
submission, it's a local fix for a problem that network folks will
likely fix up differently... but who knows, showing what I did about it
after taking a look could perhaps save a wee bit of labor, so...

Hohum, so much for good intentions.  I though I was clearly showing
that separation of the polling business was not as complete as other
changes led me to believe it is intended to be.

> Second, you must provide the complete set of build failure details
> so that anyone just reading your posting can understand and fully
> review your patch without having to go anywhere else for the
> pertinent information.

Here's the naked failure instead.

  CC      net/core/dev.o
net/core/dev.c: In function ‘napi_hash_add’:
net/core/dev.c:5315:43: error: ‘MIN_NAPI_ID’ undeclared (first use in this function)
   if (unlikely(++napi_gen_id < MIN_NAPI_ID))
                                           ^
net/core/dev.c:5315:43: note: each undeclared identifier is reported only once for each function it appears in
scripts/Makefile.build:302: recipe for target 'net/core/dev.o' failed
make[1]: *** [net/core/dev.o] Error 1
Makefile:1663: recipe for target 'net/core/dev.o' failed
make: *** [net/core/dev.o] Error 2

	-Mike
