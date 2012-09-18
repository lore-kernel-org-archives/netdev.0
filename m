From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [RFC PATCH v1 0/3] usbnet: runtime suspend when link becomes down
Date: Tue, 18 Sep 2012 22:23:18 +0800
Message-ID: <1347978201-6219-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, Fink Dmitry <finik-l0cyMroinI0@public.gmane.org>,
	Rafael Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Currently only very few usbnet devices support the traffic based
runtime PM, eg. wake up devices if there are packets to be transmitted.

For the below situation, it should make sense to runtime suspend usbnet
device to save power:

	- after network link becomes down

This patch implements the runtime PM triggered by network link change
event, and it works basically on asix usbnet device after a simple
runtime PM test.

Change Log:
v1:
	-- use system_freezable_wq to fix deadlock by calling
	usbnet_link_updated in same workqueue
	-- use system_freezable_wq to stop link check work during
	system sleep
	-- fix bug of possible change of previous autosuspend_delay
	-- set/clear 'needs_remote_wakeup' for devices which support
	remote wakeup on link change
	-- convert EXPORT_SYMBOL_GPL to EXPORT_SYMBOL
	-- introduce module parameter of link_autocheck_time
	-- introduce link_rpm_supported to not start link
	runtime PM for devices which can't detect link change
	(such as smsc95xx)

	Thanks for Oliver's review.

 drivers/net/usb/asix_devices.c |    6 +-
 drivers/net/usb/cdc_ether.c    |    5 +-
 drivers/net/usb/cdc_ncm.c      |    9 +-
 drivers/net/usb/dm9601.c       |    7 +-
 drivers/net/usb/mcs7830.c      |    6 +-
 drivers/net/usb/sierra_net.c   |    6 +-
 drivers/net/usb/usbnet.c       |  280 +++++++++++++++++++++++++++++++++++++++-
 include/linux/usb/usbnet.h     |   22 +++-
 8 files changed, 306 insertions(+), 35 deletions(-)


Thanks,
--
Ming Lei

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
