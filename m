From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] netlink: fix overrun in attribute iteration
Date: Thu, 11 Sep 2008 23:02:44 -0700
Message-ID: <20080911230244.d76a7310.akpm@linux-foundation.org>
References: <20080911205933.GA20032@localhost.localdomain>
	<20080911165243.125a74cc.akpm@linux-foundation.org>
	<19f34abd0809112242p27928541ydbfbb60ed84e34d2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch,
	penberg@cs.helsinki.fi, mingo@elte.hu, viro@zeniv.linux.org.uk,
	linux-kernel@vger.kernel.org
To: "Vegard Nossum" <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59544 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751441AbYILGDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 02:03:11 -0400
In-Reply-To: <19f34abd0809112242p27928541ydbfbb60ed84e34d2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Sep 2008 07:42:36 +0200 "Vegard Nossum" <vegard.nossum@gmail.com> wrote:

> On Fri, Sep 12, 2008 at 1:52 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Thu, 11 Sep 2008 22:59:33 +0200
> > Vegard Nossum <vegard.nossum@gmail.com> wrote:
> >
> >>   #include <stdio.h>
> >>
> >>   main(void)
> >>   {
> >>           printf("%d\n", -1 >= sizeof(int));
> >>   }
> >>
> >
> > akpm:/home/akpm> gcc -W t.c
> > t.c: In function 'main':
> > t.c:5: warning: comparison between signed and unsigned
> >
> > Make of that what you will :)
> 
> It doesn't show up with -Wall and the kernel isn't compiled with -W
> (aka. -Wextra) as far as I can see. Should it be turned on?
> 

Last time I turned on -W, a full kernel build emitted nearly 10MB of
warnings.

Alas, some of them are useful, as we see here.  They can be turned on
piecemeal - this one is -Wsign-compare, I think.

I think it would be good if owners of particular parts of the kernel
were to occasionally build their stuff with -W and spend half an hour
contemplating the result.  Ditto `make C=1', to see what sparse thinks.


