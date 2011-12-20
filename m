From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: (unknown)
Date: Tue, 20 Dec 2011 18:06:03 +0200
Message-ID: <1324397163-302-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<timo.teras@iki.fi>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:37413
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751611Ab1LTQGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 11:06:45 -0500
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

I did not have the time to test and send a v2 for my patch to remove the leftover local_bh_disable()/local_bh_enable() Ben has spotted.
I've also tried to use your approach but in my tests, under high load, the defered work was defered forever...

I'll try to test again with your patch and confirm it does not suffer from this issue or send a patch with those local_bh removed.

Madalin

-----Original Message-----
From: Steffen Klassert [mailto:steffen.klassert@secunet.com] 
Sent: Tuesday, December 20, 2011 10:24 AM
To: David Miller
Cc: Bucur Madalin-Cristian-B32716; eric.dumazet@gmail.com; netdev@vger.kernel.org; timo.teras@iki.fi
Subject: Re: [PATCH] net/flow: remove sleeping and deferral mechanism from flow_cache_flush

On Tue, Sep 27, 2011 at 03:31:32PM -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 27 Sep 2011 15:28:36 -0400 (EDT)
> 
> > afinfo->garbage_collect is the only other place 
> > afinfo->__xfrm_garbage_collect
> > is referenced, and that is completely unused and should thus be 
> > deleted (I'll take care of that in net-next).
> 
> Nevermind I see how these are referenced directly via xfrm4_policy.c 
> and xfrm6_policy.c, sigh...

Is there any progress in fixing this issue? I've seen this occasionally on some of our production systems, so I fixed it for us in the meantime with the patch below. I could submit this for inclusion if noone else wants to fix it in a different manner.
