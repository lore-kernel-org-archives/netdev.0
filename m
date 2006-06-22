From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Thu, 22 Jun 2006 14:41:52 -0400
Message-ID: <1151001712.5392.47.camel@jzny2>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>  <4497474C.4050706@trash.net>
	 <1150815375.5270.78.camel@jzny2>  <44980FA3.1000009@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>, hawk@diku.dk,
	russell-tcatm@stuart.id.au, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:40077 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751096AbWFVSmB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 14:42:01 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FtU7w-0002z6-C8
	for netdev@vger.kernel.org; Thu, 22 Jun 2006 14:42:04 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44980FA3.1000009@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-20-06 at 17:09 +0200, Patrick McHardy wrote:
> jamal wrote:

> "Depend on bandwidth" is not the right term. All of TBF, HTB and HFSC
> provide bandwidth per time, but with TBF and HTB the relation between
> the amount of bandwidth is linear to the amount of time, with HFSC
> it is only on a linear on larger scale since it uses service curves,
> which are represented as two linear pieces. So you have bandwidth b1
> for time t1, bandwidth b2 after that until eternity. By scaling the
> clock rate you alter after how much time b2 kicks in, which affects
> the guaranteed delays. The end result should be that both bandwidth
> and delay scale up or down proportionally, but I'm not sure that this
> is what HFSC would do in all cases (on small scale). But it should
> be easy to answer with a bit more time for visualizing it.
> 

Ok, this makes things a little trickier though, no? 

> The thing I'm not sure about is whether this wouldn't be handled better
> by userspace, 

If you do it in user space you will need a daemon of some form; this is
my preference but it seems a lot of people hate daemons - the standard
claim is it is counter-usability. Such people are forgiving if you built
the daemon into the kernel as a thread. Perhaps the netcarrier that
Stefan Rompf has added could be extended to handle this)
Note, if you wanna do it right as well you will factor in other things
like some wireless technologies which changes their throughput
capability over a period of time ( A lot of these guys try to have their
own hardware level schedulers to compensate for this).

> if the link layer speed changes you might not want
> proportional scaling but prefer to still give a fixed amount of that
> bandwidth to some class, for example VoIP traffic. Do we have netlink
> notifications for link speed changes?

Not there at the moment - but we do emit event for other link layer
stuff like carrier on/off - so adding this should be trivial and a
reasonable thing to have; with a caveat: it will be link-layer specific;
so whoever ends up adding will have to be careful to make sure it is not
hard-coded to be specific to ethernet-like netdevices. It could probably
be reported together with link state as a TLV like ETHER_SPEED_CHANGED
which carries probably old speed and new speed
and maybe even reason why it changed.

cheers,
jamal

