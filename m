From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: limit window scaling if window is clamped
Date: Fri, 18 Aug 2006 20:03:23 -0700
Message-ID: <20060818200323.40b1a74a@localhost.localdomain>
References: <20060818102938.5abc1bcf@dxpl.pdx.osdl.net>
	<20060818.170030.74563682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58273 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751258AbWHSDED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 23:04:03 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060818.170030.74563682.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 18 Aug 2006 17:00:30 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Fri, 18 Aug 2006 10:29:38 -0700
> 
> > This small change allows for easy per-route workarounds for broken hosts or
> > middleboxes that are not compliant with TCP standards for window scaling.
> > Rather than having to turn off window scaling globally. This patch allows
> > reducing or disabling window scaling if window clamp is present.
> > 
> > Example: Mark Lord reported a problem with 2.6.17 kernel being unable to
> > access http://www.everymac.com
> > 
> > # ip route add 216.145.246.23/32 via 10.8.0.1 window 65535
> > 
> > I would argue this ought to go in stable kernel as well.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> I want to think about this some more, it might have unintended
> consequences.  I really am not all that thrilled about putting in
> workaround for this problem especially if it hurts a legitimate use of
> some kind.

I was going for the least impact workaround using existing mechanisms.
There already is a way to set metrics per route. The code already limits
the window scale to the maximum possible window based on tcp memory limit
so it made sense to clamp based on congestion window as well.
It didn't make sense to add a new metric.
