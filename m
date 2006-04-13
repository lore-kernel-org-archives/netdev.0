From: Roger Luethi <rl@hellgate.ch>
Subject: Re: via_rhine modules error on 2.6.16 with mii-tool
Date: Thu, 13 Apr 2006 22:31:48 +0200
Message-ID: <20060413203147.GA2874@k3.hellgate.ch>
References: <BAY103-F401F96F0B06D75E70AF0BFB2DF0@phx.gbl> <20060327203946.GA11824@k3.hellgate.ch> <20060413182638.GC25854@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marco Berizzi <pupilla@hotmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail15.bluewin.ch ([195.186.18.63]:1770 "EHLO mail15.bluewin.ch")
	by vger.kernel.org with ESMTP id S964868AbWDMUcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 16:32:52 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060413182638.GC25854@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Apr 2006 14:26:43 -0400, John W. Linville wrote:
> > I wonder if low latency for ancient Rhine-I chips is worth the trouble.
> 
> IIRC, the point was that mdelay was getting called in interrupt
> context and causing ugly messages to show-up in dmesg.

I suppose the patch back then was to reduce latency; the ugly messages in
the kernel ring buffer were _introduced_ with the patch (you shouldn't get 
error messages calling mdelay in interrupt context because that's what
mdelay is for).

> Would the patch below be sufficient?  Or does the whole patch need
> to be reverted?

I'd revert the whole thing. There's no point in having the additional
work_struct complexity if we end up calling mdelay anyway.

Roger
