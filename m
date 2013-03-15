From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v3 0/7] USB: don't recover device if suspend fails in system sleep
Date: Fri, 15 Mar 2013 12:08:52 +0800
Message-ID: <1363320539-23012-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

This patch adds comments on interface driver suspend callback
to emphasize that the failure return value is ignored by
USB core in system sleep context, so do not try to recover
device for this case, otherwise the recovery things may confuse
resume().

Also fixes USB HID and several usbnet drivers which may recover
device in suspend failure path of system sleep.

v3:
	- only 2/7 changed, don't change code but add comments to
	restrict subdriver->suspend(), suggested by Johan Hovold.

v2:
        - improve comments on suspend callback as suggested by Alan
        - update kerneldoc for usb_suspend_both as suggested by Alan
        - remove previous check of PMSG_IS_AUTO(message) in cdc_mbim/
        qmi_wwan and add comments on suspend failure case, since Bj=C3=B8=
rn
        doesn't like the check.
        - add comments on smsc95xx/smsc75xx
v1:
        - fix compile failure
        - add comments about handling suspend failure in resume()

 drivers/hid/usbhid/hid-core.c   |   14 +++++---------
 drivers/net/usb/cdc_mbim.c      |    5 +++++
 drivers/net/usb/qmi_wwan.c      |    5 +++++
 drivers/net/usb/smsc75xx.c      |    6 +++++-
 drivers/net/usb/smsc95xx.c      |    6 +++++-
 drivers/usb/core/driver.c       |   11 ++++++++---
 drivers/usb/serial/usb-serial.c |    5 +++++
 include/linux/usb.h             |    7 ++++++-
 8 files changed, 44 insertions(+), 15 deletions(-)


Thanks
--
Ming Lei

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
