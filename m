From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 16/17] d80211: fix monitor interfaces
Date: Fri, 21 Apr 2006 22:49:35 +0200
Message-ID: <20060421224935.5acd79bf@griffin.suse.cz>
References: <20060421201147.D4F76482CF@silver.suse.cz>
	<1145651369.3897.33.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:58791 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932436AbWDUUth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:49:37 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1145651369.3897.33.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Apr 2006 22:29:29 +0200, Johannes Berg wrote:
> On Fri, 2006-04-21 at 22:11 +0200, Jiri Benc wrote:
> 
> > Also, "soft" and "hard" monitor modes are introduced.
> 
> What's the distinction? The code might want some comments about what
> that
> 
> > +       /* Device is capable of performing full monitor mode even during
> > +        * normal operation. */
> 
> actually means. I suppose it means that the device will receive control
> frames too, but I don't know if that's right.

Some devices need to be switched to completely different mode to be able
to receive all frames (including control ones) or even load another
firmware. Such devices are not capable to transmit anything while in
monitor mode and their drivers won't set monitor_during_oper.

Another devices are capable to receive all frames while continuing their
normal operation. Driver will probably set monitor_during_oper in that
case.

"Hard" monitor mode means the card is operating in a true rfmon mode -
i.e. you get everything on the given channel. "Soft" monitor mode means
that you will get only frames the device is willing to give you at the
time - this probably means only frames belonging to your BSS in case of
fullmac cards.

So, you can always do

echo -n sta0 > /sys/class/ieee80211/wiphy0/add_iface
echo -n mon0 > /sys/class/ieee80211/wiphy0/add_iface
iwconfig sta0 mode managed
iwconfig mon0 mode monitor
ifconfig sta0 up
ifconfig mon0 up

and this will work - independently of the value of monitor_during_oper.
The difference is that in case of monitor_during_oper == 0, you won't
probably receive much more frames from mon0 than from sta0. But - you
will most likely receive beacons on mon0 and also monitoring headers
(prism2 headers presently).

When monitor_during_oper == 1, you are able to watch all traffic on the
current channel on mon0 without interrupting normal functionality.

-- 
Jiri Benc
SUSE Labs
