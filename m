From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v1 00/11] usbnet: usb_control_msg cleanup
Date: Thu, 11 Oct 2012 20:39:18 +0800
Message-ID: <1349959169-9432-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

This patch set introduces 3 helpers for handling usb read, write
and write_async command, and replaces the low level's implemention
with the generic ones.

This patchset is a cleanup and about 300 lines code can be saved.

Also, the patchset fixes problem of DMA on buffer embedded inside
one dynamic allocated buffer, and such usages can be found
in cdc-ncm, sierra_net, mcs7830 and asix drivers.

v1:
	- drop previous patch 12, and let net/core handle
	runtime PM in ioctl path

 drivers/net/usb/asix_common.c |  117 ++++--------------------------------
 drivers/net/usb/cdc_ncm.c     |   73 +++++++---------------
 drivers/net/usb/dm9601.c      |  107 +++++----------------------------
 drivers/net/usb/int51x1.c     |   52 +---------------
 drivers/net/usb/mcs7830.c     |   85 ++------------------------
 drivers/net/usb/net1080.c     |  110 ++++++++++------------------------
 drivers/net/usb/plusb.c       |   11 ++--
 drivers/net/usb/sierra_net.c  |   45 ++++++--------
 drivers/net/usb/smsc75xx.c    |   39 +++++-------
 drivers/net/usb/smsc95xx.c    |  115 +++++++++--------------------------
 drivers/net/usb/usbnet.c      |  133 +++++++++++++++++++++++++++++++++++++++++
 include/linux/usb/usbnet.h    |    6 ++
 12 files changed, 291 insertions(+), 602 deletions(-)

Thanks,
--
Ming Lei

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
