From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH] zd1211rw-d80211: Use LED class
Date: Tue, 12 Dec 2006 23:38:35 +0100
Message-ID: <20061212223835.GA8487@p15091797.pureserver.info>
References: <200612110044.12205.flamingice@sourmilk.net> <20061211225538.GA30512@p15091797.pureserver.info> <200612112032.08646.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:58173 "EHLO
	p15091797.pureserver.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932503AbWLLWig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 17:38:36 -0500
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200612112032.08646.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-12-11 20:32 Michael Wu wrote:

> On Monday 11 December 2006 17:55, Ulrich Kunitz wrote:
> > I cannot accknowledge this patch. Michael, the LED does not only
> > show the link status, but also indicate that packets are sent,
> > which is done by the firmware. However the LED flags have to be
> > reset every second, because if an odd number of packets have been
> > transmitted, the LED stays dark.
> The d80211 TX trigger has the same behavior. It's probably worse on single LED 
> devices since it may look like nothing is on. Even then, I think having it 
> reset every second is overkill. Having an "TX LED" watchdog run when we 
> haven't TXed anything for the last second or sounds better to me. This would 
> force the LEDs to a reasonable state when we know nothing has been TXed 
> recently. This could be for STA mode only.. I dunno if the LED blinks when 
> sending hardware generated/filled beacons.

Micheal, how resetting an LED every second is overkill is beyond
me. On a USB 2.0 port the available bandwidth is much higher than
on the air. Notify also that the LED is flip-flopped on tx packets
(which might include ACKs), so you simply don't know, when it
becomes dark. If nothing is transmitted the LED stays on, but if
something is transmitted you might have to guess. That's the
reason why I added the reset code. BTW the driver makes the LED
blinks in a certain sequence (1s on, 2s off) while scanning. It is
quite useful for debugging. You cannot do that without workqueues.

> The upper layer does not know about the LEDs of individual devices. It merely 
> provides a number of LED triggers which device drivers can choose to listen 
> to - which sounds like what you're suggesting.

No, this is not true. The upper layer has to support a Link-LED
trigger. I believe that event triggers are a generic concept and
should not be LED-specific. These triggers should inform about
LINK status changes and the driver has to know, whether it has a
LINK LED to switch or a LCD to display some information. There
might be also other uses than for switching LEDs.

> Switching to using LED class makes the housekeeping & workqueue code not do 
> anything useful, so I removed it. I am not against the housekeeping & 
> workqueue code - but right now this is dead code that will unnecessarily 
> cause zd1211rw-d80211 not to compile when wireless-dev gets the workqueue api 
> changes. (of course, d80211 doesn't compile either with the workqueue 
> changes, but I'm working out a patch for that..)

No, it is not dead code as I explained.  Your patch is removing
functionality and if I undestand right, might work in the future.
But it is not tested and doesn't care for the activity
flip-flopping.

Regards,

Uli


-- 
Uli Kunitz
