From: Paul Moore <pmoore@redhat.com>
Subject: Re: TUN problems (regression?)
Date: Fri, 21 Dec 2012 11:27:57 -0500
Message-ID: <2090364.S7KStA6R4d@sifl>
References: <4151394.nMo40zlg68@sifl> <1356046697.21834.3606.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3491 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091Ab2LUQ23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2012 11:28:29 -0500
In-Reply-To: <1356046697.21834.3606.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, December 20, 2012 03:38:17 PM Eric Dumazet wrote:
> On Thu, 2012-12-20 at 18:16 -0500, Paul Moore wrote:
> > [CC'ing netdev in case this is a known problem I just missed ...]
> > 
> > Hi Jason,
> > 
> > I started doing some more testing with the multiqueue TUN changes and I
> > ran
> > into a problem when running tunctl: running it once w/o arguments works as
> > expected, but running it a second time results in failure and a
> > kmem_cache_sanity_check() failure.  The problem appears to be very
> > repeatable on my test VM and happens independent of the LSM/SELinux fixup
> > patches.
> > 
> > Have you seen this before?
> 
> Obviously code in tun_flow_init() is wrong...
> 
> static int tun_flow_init(struct tun_struct *tun)
> {
>         int i;
> 
>         tun->flow_cache = kmem_cache_create("tun_flow_cache",
>                                             sizeof(struct tun_flow_entry),
> 0, 0, NULL);
>         if (!tun->flow_cache)
>                 return -ENOMEM;
> ...
> }
> 
> 
> I have no idea why we would need a kmem_cache per tun_struct,
> and why we even need a kmem_cache.
> 
> 
> I would try following patch :
> 
>  drivers/net/tun.c |   24 +++---------------------
>  1 file changed, 3 insertions(+), 21 deletions(-)

Thanks, that solved my problem.  Also, in case you were still curious, I was 
using SLUB.

-- 
paul moore
security and virtualization @ redhat
