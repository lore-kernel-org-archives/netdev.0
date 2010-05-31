From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [RFC] netfilter: WIP: Xtables idletimer target implementation
Date: Mon, 31 May 2010 23:11:38 +0300
Message-ID: <1275336698.11744.37.camel@powerslave>
References: <1274993689-23928-1-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1005280057190.14077@obet.zrqbmnf.qr>
	 <1275024304.3754.45.camel@powerslave>
	 <alpine.LSU.2.01.1005281001550.11570@obet.zrqbmnf.qr>
	 <1275040724.24490.121.camel@chilepepper>  <4C03DCF3.1080001@trash.net>
	 <1275333179.11744.23.camel@powerslave>
	 <alpine.LSU.2.01.1005312143470.23758@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ext Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Timo Teras <timo.teras@iki.fi>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:31428 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757278Ab0EaUSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 16:18:11 -0400
In-Reply-To: <alpine.LSU.2.01.1005312143470.23758@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-05-31 at 21:51 +0200, ext Jan Engelhardt wrote:
> On Monday 2010-05-31 21:12, Luciano Coelho wrote:
> >
> >I considered this option, but then I didn't find a proper place where to
> >include the attribute in sysfs, since I cannot add it as part of the
> >interface (eg. /sys/class/net/wlan0/idletimer) as I was doing before.
> 
> You couldn't have done that before either, because the interface name
> in ipt_ip may refer to an interface that does not exist at all times.

True.  That's why I was using netdevice_notifiers , so that I would
monitor the interface state and add the idletimer attribute when a timer
was associated with the interface that went up.  But now the rules are
not interface specific, so it cannot be done like that anymore.


> >The other option would be to make the idletimer as part of the
> >xt_IDLETIMER module object in sysfs
> >(ie. /sys/module/xt_IDLETIMER/<user_supplied_name>), but it looks out of
> >place.
> 
> I like it. It follows /proc/net/xt_{hashlimit,recent}/<user_supplied_name>.
> 
> >And I think adding it as /sys/class/net/idletimer is most likely
> >out of the question.
> 
> It follows /sys/class/leds/...
> 
> 
> I'm impartial though.

Okay, so this can be done in either place.  I tend to
prefer /sys/class/net/idletimer.

What about my other proposal of creating generic timers and associating
them with certain interfaces whenever we get a hit? I mean, to add the
idletimer attribute to eg. /sys/class/net/wlan0/idletimer when a packet
reaches the target from wlan0?


-- 
Cheers,
Luca.

