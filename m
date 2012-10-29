From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 0/4] usbnet: avoiding access auto-suspended device
Date: Mon, 29 Oct 2012 15:45:05 +0800
Message-ID: <1351496709-26934-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thip patchset avoids accessing auto-suspended device in ioctl path,
which is generally triggered by some network utility(ethtool, ifconfig,
...)

Most of network devices have the problem, but as discussed in the
thread:

	http://marc.info/?t=135054860600003&r=1&w=2

the problem should be solved inside driver.

Considered that only smsc75xx and smsc95xx calls usbnet_read_cmd()
and usbnet_write_cmd() inside its resume and suspend callback, the
patcheset introduce the nopm version of the two functions which
should be called only in the resume and suspend callback. So we
can solve the problem by runtime resuming device before doing
control message things.

The patchset is against 3.7.0-rc3-next-20121029, and has been tested
OK on smsc95xx usbnet device.

 drivers/net/usb/smsc75xx.c |  133 +++++++++++++++++++++++++++-----------------
 drivers/net/usb/smsc95xx.c |  122 ++++++++++++++++++++++++++--------------
 drivers/net/usb/usbnet.c   |   72 ++++++++++++++++++++++--
 include/linux/usb/usbnet.h |    4 ++
 4 files changed, 233 insertions(+), 98 deletions(-)

Thanks,
--
Ming Lei

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
