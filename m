From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] always export sysctl_{r,w}mem_max
Date: Fri, 26 Oct 2007 16:39:58 -0700 (PDT)
Message-ID: <20071026.163958.171785530.davem@davemloft.net>
References: <20071026230807.GE30533@stusta.de>
	<m1zly5wjie.fsf@ebiederm.dsl.xmission.com>
	<472278E3.4000909@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, bunk@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59860
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932147AbXJZXj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 19:39:57 -0400
In-Reply-To: <472278E3.4000909@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 26 Oct 2007 16:31:47 -0700

> Eric W. Biederman wrote:
> > Adrian Bunk <bunk@kernel.org> writes:
> > 
> > 
> >>This patch fixes the following build error with CONFIG_SYSCTL=n:
> >>
> >><--  snip  -->
> >>
> >>...
> >>ERROR: "sysctl_rmem_max" [fs/dlm/dlm.ko] undefined!
> >>ERROR: "sysctl_wmem_max" [drivers/net/rrunner.ko] undefined!
> >>ERROR: "sysctl_rmem_max" [drivers/net/rrunner.ko] undefined!
> >>make[2]: *** [__modpost] Error 1
> > 
> > 
> > I was going to ask if allowing drivers to increase rmem_max
> > is something that we want to do.  Apparently the road runner
> > driver has been doing this since the 2.6.12-rc1 when the
> > git repository starts so this probably isn't a latent bug.
> 
> Although it does rather sound like a driver writer yanking the rope from the 
> hand's of the sysadmin and hanging him with it rather than letting the sysadmin 
> do it himself.  I've seen other drivers' README's suggesting larger mem's but 
> not their sources doing it.

I really don't think what the roadrunner driver is doing is
correct at all.

I also think what DLM is doing is wrong too.

If DLM really wants minimum, it can use SO_SNDBUFFORCE and
SO_RCVBUFFORCE socket options and use whatever limits it
likes.

But even this is questionable.

I'll put in Adrian's patch to fix the build as a first
priority, but in the long term this cruft has gotta go.
