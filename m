From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Keystone 2 boards boot failure
Date: Mon, 08 Feb 2016 14:59:45 +0100
Message-ID: <2472114.LQO1Tp1DqS@wuerfel>
References: <56B0DE61.2000704@ti.com> <2480415.iC3bxkK7OM@wuerfel> <56B4D7AA.1000309@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "Franklin S Cooper Jr." <fcooper@ti.com>, m-karicheri2@ti.com,
	netdev@vger.kernel.org, w-kwok2@ti.com, davem@davemloft.net,
	Santosh Shilimkar <ssantosh@kernel.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:59407 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328AbcBHOAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 09:00:00 -0500
In-Reply-To: <56B4D7AA.1000309@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 05 February 2016 19:11:06 Grygorii Strashko wrote:
> On 02/05/2016 06:18 PM, Arnd Bergmann wrote:
> > On Thursday 04 February 2016 18:25:08 Grygorii Strashko wrote:

> > @@ -1173,7 +1189,8 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
> >   	}
> >   
> >   	set_words(&tmp, 1, &desc->packet_info);
> > -	set_words((u32 *)&skb, 1, &desc->pad[0]);
> > +	tmp = (uintptr_t)&skb;
> > +	set_words(&tmp, 1, &desc->pad[0]);
> 
> &skb is virt address and its size is 32bit even when LPAE=y (phys/dma 64 bit)
> so  this is excess conversion to/from u64 ;)
> This is from the first look.

My original patch attempted to fix support for 64-bit CPUs, as no driver
should be written to support only 32-bit CPUs even if you think at this
point that there can never be a 64-bit keystone system.

The half-reverted patch above no longer works correctly for 64-bit CPUs
but it should not actually be wrong on 32-bit CPUs either, unless I'm
missing your point. 

> >   
> >   	if (tx_pipe->flags & SWITCH_TO_PORT_IN_TAGINFO) {
> >   		tmp = tx_pipe->switch_to_port;
> > 
> > 
> > I'm sure it's something obvious and stupid in there, but I just can't
> > see it and that is very unsatisfying. Do you see where I am going wrong?
> > Most of all, I want to know it so I don't make the same mistake again
> > when I patch another driver.
> > 
> 
> I'm very sorry, but I'll not be able to test it in the nearest future :(
> What I could do now is update your/my patch as i mentioned in [1]
> and re-send it at the weekend (with your authorship and my signoff).
> Do you agree?
> 
> 
> [1] https://www.mail-archive.com/netdev@vger.kernel.org/msg95831.html

Yes, let's do that in the meantime. I can also make sure that that
the driver doesn't build on 64-bit, just in case.

	Arnd
