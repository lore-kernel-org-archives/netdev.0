From: David Brownell <david-b@pacbell.net>
Subject: Re: Patch: link state notification for 2.5.41
Date: Sat, 12 Oct 2002 08:10:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DA83B79.3060302@pacbell.net>
References: <Pine.GSO.4.30.0210120857550.23509-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[ CCs trimmed ]


> BTW, did you ping the USB people on notPresent? At least one of them i
> think participated in that discussion.

That was likely me.  :)


> -Anyway, I wanted to keep the current semantics of
> netif_carrier_on()/_off(). The extended states that can be found RFC2863
> did not seem to useful to me for linux, mainly because "notPresent" is
> already implemented with netif_device_detach()/_attach() and especially
> for ethernet drivers there is no real difference between "testing" and
> "down".

The "link active" issue for hotplug is perhaps just that while userspace
sees /sbin/hotplug notifications when network interfaces are registered
or unregistered, the right time to autoconfigure is actually when the
link connects to a net ... or reconnects to a different one.  So we
really want (hotplug) events other than link register/unregister.  (And
some systems will want the events through a daemon instead.)

So long as there's a clean way to generate such events, and to use them
to trigger autoconfiguration, my basic concern is addressed.  Delivery
issues should be a lot easier to resolve.  I think I mentioned the
notPresent bit purely as an RFC conformance issue, since I was trying
to make sense of what the kernel code was expected/intended to do.

- Dave
