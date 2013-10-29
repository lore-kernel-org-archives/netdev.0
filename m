From: Meelis Roos <mroos@linux.ee>
Subject: Re: 3.12-rc7 regression - network panic from ipv6
Date: Tue, 29 Oct 2013 23:38:28 +0200 (EET)
Message-ID: <alpine.SOC.1.00.1310292338010.22172@math.ut.ee>
References: <alpine.SOC.1.00.1310292221550.19416@math.ut.ee> <20131029210758.GA18323@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, steffen.klassert@secunet.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131029210758.GA18323@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Some bad news - in a system where 3.12-rc6 and earlier worked fine, 
> > 3.12-rc7 panics or hangs repeatedly with network traffic (torrent being 
> > good test). First there is BUG from ipv6 code, followed by panic.
> 
> Could you do a bisect on this? There seems to be one commit for this
> particular function _decode_session6:
> 
> commit bafd4bd4dcfa13145db7f951251eef3e10f8c278
> Author: Steffen Klassert <steffen.klassert@secunet.com>
> Date:   Mon Sep 9 10:38:38 2013 +0200
> 
>     xfrm: Decode sessions with output interface.
>     
>     The output interface matching does not work on forward
>     policy lookups, the output interface of the flowi is
>     always 0. Fix this by setting the output interface when
>     we decode the session.
> 
> Maybe try to just revert this change locally and try again?

Yes, just reverting this patch on top of rc7 gets rid of the problem for 
me.

-- 
Meelis Roos (mroos@linux.ee)
