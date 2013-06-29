From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 0/7] alx: small fixes/cleanups
Date: Sat, 29 Jun 2013 19:20:36 +0200
Message-ID: <1372526436.8183.3.camel@jlt4.sipsolutions.net>
References: <1372185503-24705-1-git-send-email-johannes@sipsolutions.net>
	 <20130625210102.GA18495@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Stezenbach <js@sig21.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:58296 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629Ab3F2RUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 13:20:45 -0400
In-Reply-To: <20130625210102.GA18495@sig21.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-25 at 23:01 +0200, Johannes Stezenbach wrote:
> On Tue, Jun 25, 2013 at 08:38:16PM +0200, Johannes Berg wrote:
> > Thanks to Ben's review mostly, here are some fixes/cleanups in
> > alx. I'm seriously considering removing WoWLAN as I have no use
> > for it and am not too motivated to debug it, anyone else want
> > to try debugging? :)
> 
> One thing I noticed is alx_select_powersaving_speed() will return 0
> when there is no link but leaves *speed uninitialized.

Yeah, that's a bit odd.

> Then __alx_shutdown() prints e.g.
>    alx 0000:03:00.0 eth0: wol: ctrl=3, speed=FFFF8801
> In this case the
>   alx_write_phy_reg(hw, ALX_MII_IER, 0);
> is skipped in alx_select_powersaving_speed().
> However, it should still be done in alx_pre_suspend()
> when WOL is disabled.  But it might be we need to move
> the alx_clear_phy_intr() in __alx_shutdown() down.
> 
> I'm also not sure why alx_get_phy_link() reads MII_BMSR
> twice, but the old driver from compat-wireless-3.6.8-1-snpc
> also does it, it seems deliberate.

Yeah, all this looks like magic to me...

> Unless someone beats me to it I will try to debug
> on the weekend.

The whole PCI(e) stuff there looks pretty odd to me and I can't seem to
fix it right now, so I'm removing it. It really looks like all the
wakeup_enable() etc. is in the wrong places? Hmmm. Well the code is
still in the history ;-)

> BTW, it is WoLAN not WoWLAN :-)

Heh, oops. Guess it shows what I usually work on ;-)

johannes
