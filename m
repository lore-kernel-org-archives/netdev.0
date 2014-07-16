From: Michalis Pappas <mpappas-97jfqw80gc6171pxa8y+qA@public.gmane.org>
Subject: How to replace control code in gdm72xx?
Date: Wed, 16 Jul 2014 21:24:28 +0100
Message-ID: <53C6DF7C.8030109@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: inaky-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, Ben Chan <benchan-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I'm currently working on bringing the gdm72xx WiMAX driver out of
staging. The driver currently uses two control channels:

1. The SIOCDEVPRIVATE ioctl to send and receive state messages

2. A customly defined netlink protocol for passing messages verbatim to
the device controller

AFAIK both of the above are deprecated, so I considered switching to
the interface defined in wimax.h, which defines a communication protocol
over generic netlink that replaces (2) nicely. However it is not
compatible with (1), as:

* Except from the device status, the gdm72xx driver uses two more types
of messages (connection and OMA status), which is not supported
by wimax.h.

* The gdm driver needs to be able to receive status messages from
userspace, which is not supported by wimax.h either.

I therefore consider using the wimax stack as defined in wimax.h for the
netlink part, but replacing the ioctl with a file under /sys/class/net/wm0/

My questions are whether the above location would be the right place for
that file, and, more importantly, whether this is a generally a valid
approach and not just an ugly workaround.

Thanks,

Michalis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
