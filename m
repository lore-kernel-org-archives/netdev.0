From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH] zd1211rw-d80211: Use LED class
Date: Wed, 13 Dec 2006 23:54:52 +0100
Message-ID: <20061213225452.GC20700@p15091797.pureserver.info>
References: <200612110044.12205.flamingice@sourmilk.net> <200612112032.08646.flamingice@sourmilk.net> <20061212223835.GA8487@p15091797.pureserver.info> <200612121826.38479.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:55383 "EHLO
	p15091797.pureserver.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbWLMWyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 17:54:53 -0500
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200612121826.38479.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael,

please detach a little bit from LEDs.

A trigger is a generic concept. It doesn't need to have a special
binding to what it triggers. It could be a buzzer, it could be
an LED, it could be text output on an LCD.

So we could have link status change trigger, for which functions
could be registered. There is no reason for the upper layer d80211
code to know, that it triggers an LED. A netlink event generator
could only be one of the users of those generic triggers.

My other opinion is that I find it overkill to handle the LED on a
WLAN adapter as an independent device instantiating a device class
in Linux. I mean on the other hands we break APIs for four or
eight bytes and here we spend a whole device strucuture and sysfs
directory for something the wlan device firmware represents with a
single bit. To call the housekeeping functions overkill under
these circumstances appears not to be very rational.

It should also be mentioned that the LEDs on the ZD1211 devices
are not independent devices, because they are partly controlled
by the firmware. That's exactly where some of the issues with your
patch are.

Let the device drivers do the blinking, but give them a chance to
know about status changes at the MAC layer, without mandating to
implement a LED device. Using the same triggers by a netlink event
generator, would make the code even simpler.

-- 
Uli Kunitz
