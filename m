From: David Miller <davem@davemloft.net>
Subject: Re: rtnetlink: propagate error from dev_change_flags in
 do_setlink()
Date: Sun, 16 Nov 2008 23:21:00 -0800 (PST)
Message-ID: <20081116.232100.91284662.davem@davemloft.net>
References: <1226841029.3644.2.camel@johannes.berg>
	<1226841368.3644.6.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32952
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752684AbYKQHVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 02:21:00 -0500
In-Reply-To: <1226841368.3644.6.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sun, 16 Nov 2008 14:16:08 +0100

> On Sun, 2008-11-16 at 14:10 +0100, Johannes Berg wrote:
> > Unlike ifconfig, iproute doesn't report an error when setting
> > an interface up fails:
> > 
> > (example: put wireless network mac80211 interface into repeater mode
> > with iwconfig but do not set a peer MAC address, it should fail with
> > -ENOLINK)
> > 
> > without patch:
> > # ip link set wlan0 up ; echo $?
> > 0
> > # 
> > 
> > with patch:
> > # ip link set wlan0 up ; echo $?
> > RTNETLINK answers: Link has been severed
> > 2
> > # 
> > 
> > Propagate the return value from dev_change_flags() to fix this.
> > 
> > Signed-off-by: Patrick McHardy <kaber@trash.net>
> > Tested-by: Johannes Berg <johannes@sipsolutions.net>
> > Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Patch applied.

> Maybe add
> Cc: stable@kernel.org [since the beginning of time^Wgit]
> 
> when committing? Not sure it's appropriate for stable since so far
> nobody complained, I suspect people just use the ioctl anyway.

I'll queue it up for -stable, thanks.
