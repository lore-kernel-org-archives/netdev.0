From: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 00/14] usb/net: rndis: first step toward consolidation
Date: Sun,  8 Apr 2012 10:46:53 +0200
Message-ID: <1333874813-3861-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The kernel currently contains four (4) disparate implementations of
different aspects of the RNDIS (Remote Network Driver Interface
Specification) protocol. This protocol is a way of marshalling the
Windows network driver model to external devices over different
bearers.

- drivers/net/usb/rndis_host: implements the protocol for USB
  ethernet (etc) dongles, an alternative to CDC ethernet. For
  example some mobile phones also expose this interface for
  easy networking.

- drivers/net/wireless/rndis_wlan: same thing for WLAN.

- drivers/usb/gadget/*rndis: the embedded counterpart, say you
  want to create one of the above devices.

- drivers/net/hyperv/rndis_filter: when virtualizing Linux inside
  windows, windows helpfully exposes a virtual "network card" which
  also use RNDIS. (Hm, would have been helpful to use virtio
  instead I guess but whatever.)

This disparate implementation isn't particularly smart, I just recently
discovered this and made this initial attempt att consolidation which
shows how we can cut down code by some 250 lines in constant definitions
alone.

This is just a starter - if we apply this we can also move over a lot
of data types to <linux/rndis.h> and cut down even more. Then we can
potentially move code and consolidate code in a central implementation
of the protocol.

However this requires some involvement of the authors of the disparate
implementations, who need to test and help out ... I have no way to
really test this consolidation - I've dug up a USB dongle but I have
no easily patched embedded controller with a slave interface right now
and I have no Windows server with hyperv to test it on.

So if you like this, let's proceed, but if you're all in "I wanna keep
this one implementation in my corner" I'll just give up right now.

So: what do you think?

Yours,
Linus Walleij


Linus Walleij (14):
  usb/net: rndis: inline the cpu_to_le32() macro
  usb/net: rndis: break out <linux/rndis.h> defines
  usb/net: rndis: remove duplicate definitions
  usb/net: rndis: remove ambigous status codes
  usb/net: rndis: eliminate first set of duplicate OIDs
  usb/net: rndis: merge duplicate 802_* OIDs
  usb/net: rndis: delete surplus defines
  usb/net: rndis: group all status codes together
  usb/net: rndis: merge media type definitions
  usb/net: rndis: delete duplicate packet types
  usb/net: rndis: move and namespace PnP defines
  usb/net: rndis: merge command codes
  usb/net: rndis: fixup a few name prefixes
  usb/net: rndis: move bus message definition

 drivers/net/hyperv/hyperv_net.h   |  290 +----------------------------
 drivers/net/hyperv/rndis_filter.c |   46 +++---
 drivers/net/usb/rndis_host.c      |   52 +++---
 drivers/net/wireless/rndis_wlan.c |  295 ++++++++++++-----------------
 drivers/usb/gadget/f_rndis.c      |    6 +-
 drivers/usb/gadget/ndis.h         |  164 ----------------
 drivers/usb/gadget/rndis.c        |  271 +++++++++++++-------------
 drivers/usb/gadget/rndis.h        |   48 +-----
 include/linux/rndis.h             |  378 +++++++++++++++++++++++++++++++++++++
 include/linux/usb/rndis_host.h    |   66 +-------
 10 files changed, 694 insertions(+), 922 deletions(-)
 create mode 100644 include/linux/rndis.h

-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
