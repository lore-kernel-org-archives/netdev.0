From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH] Dot not insert RX urbs if EVENT_DEV_ASLEEP flag is set.
Date: Mon, 06 Dec 2010 18:49:48 -0800
Message-ID: <1291690188.2285.221.camel@helium>
References: <1291631047-23766-1-git-send-email-Indrek.Peri@Ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Indrek Peri <Indrek.Peri-rMwOiwQz3sZWk0Htik3J/w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1291631047-23766-1-git-send-email-Indrek.Peri-rMwOiwQz3sZWk0Htik3J/w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I realize it's not all your doing, but that's an EVENT not a state flag,

But you're treating it as a state flag.  (Like the original somewhat
goofy 69ee472f2706371ca639de49b06df91615c07d8d from Oliver).  Even as
a flag, its semantics seem fuzzy... like they should be covered by
other state in the network and/or power management stacks.

I'd like to see this botch fixed, not worsened.  Maybe you and Oliver
could collaborate on fixing it, and getting other state flags out ofthe
word used to track and signal events?  If you've ever worked with
hardware
that makes that kind of mistake, you know how error-prone it is ...

Meanwhile, NAK.

ISTR related Comments came up when a previous incarnation of this patch
circulated, from at least Alan Stern.  What happened to that?

Events trigger state transitions and similar actions.  So
A "leave sleep state" event" might be a place to trigger RX urb
insertion as part of wake-up processing.  (Ideally, there'd be
no need to set an event bit to trigger it as deferred work ... the
reason to have a word of event bits for some other events.




--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
