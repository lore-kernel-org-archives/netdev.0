From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: [PATCH] net: sh-eth: fix sleeping in atomic context
Date: Tue, 25 Sep 2012 19:27:13 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1209251918230.9446@axis700.grange>
References: <Pine.LNX.4.64.1209251143210.9446@axis700.grange>
 <20120925.130831.369798738695859924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-sh@vger.kernel.org, lethal@linux-sh.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20120925.130831.369798738695859924.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

On Tue, 25 Sep 2012, David Miller wrote:

> From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
> Date: Tue, 25 Sep 2012 12:38:59 +0200 (CEST)
> 
> > I'm not sure, whether this is the correct fix, i.e., whether this function 
> > is guaranteed to be called on a resumed device, but at least this fixes 
> > this specific issue in 3.6-rc7, but leaves another BUG open:
> 
> Someone added the runtime PM calls for a reason.

Sure they did.

> I cannot seriously consider your change until you are able to adequately
> consider that aspect.

I did too - as adequately as I could:-) My understanding is the following: 
assuming the networking stack is right, calling .ndo_get_stats() under a 
lock, I see 2 possibilities: (1) the method is only called during a 
running IO, i.e. the hardware cannot possibly be runtime-suspended at that 
time, so, no need to resume it; (2) the method can be called at any time, 
also when the hardware is suspended, then no IO shall be perdormed there, 
because it might involve having to wait for hardware to wake up from 
suspend. My patch fixes the former case, in the latter case statistics has 
to be collected outside of that method and inside it it only has to be 
atomically returned. This is a bigger change, if this indeed is the case, 
of course, my patch is wrong and an alternative, likely, more complex 
solution has to be found.

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
http://www.open-technology.de/
