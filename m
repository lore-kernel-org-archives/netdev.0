From: Johannes Stezenbach <js@sig21.net>
Subject: Re: [PATCH v2 0/7] alx: small fixes/cleanups
Date: Tue, 25 Jun 2013 23:01:02 +0200
Message-ID: <20130625210102.GA18495@sig21.net>
References: <1372185503-24705-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bar.sig21.net ([80.81.252.164]:38272 "EHLO bar.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802Ab3FYVCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 17:02:05 -0400
Content-Disposition: inline
In-Reply-To: <1372185503-24705-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 25, 2013 at 08:38:16PM +0200, Johannes Berg wrote:
> Thanks to Ben's review mostly, here are some fixes/cleanups in
> alx. I'm seriously considering removing WoWLAN as I have no use
> for it and am not too motivated to debug it, anyone else want
> to try debugging? :)

One thing I noticed is alx_select_powersaving_speed() will return 0
when there is no link but leaves *speed uninitialized.
Then __alx_shutdown() prints e.g.
   alx 0000:03:00.0 eth0: wol: ctrl=3, speed=FFFF8801
In this case the
  alx_write_phy_reg(hw, ALX_MII_IER, 0);
is skipped in alx_select_powersaving_speed().
However, it should still be done in alx_pre_suspend()
when WOL is disabled.  But it might be we need to move
the alx_clear_phy_intr() in __alx_shutdown() down.

I'm also not sure why alx_get_phy_link() reads MII_BMSR
twice, but the old driver from compat-wireless-3.6.8-1-snpc
also does it, it seems deliberate.

Unless someone beats me to it I will try to debug
on the weekend.

BTW, it is WoLAN not WoWLAN :-)


Thanks,
Johannes
