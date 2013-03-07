From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v2 0/7] USB: don't recover device if suspend fails in system sleep
Date: Fri,  8 Mar 2013 00:15:17 +0800
Message-ID: <1362672924-22975-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-input-owner@vger.kernel.org>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Sorry for my broken email client just now.

This patch adds comments on interface driver suspend callback
to emphasize that the failure return value is ignored by
USB core in system sleep context, so do not try to recover
device for this case, otherwise the recovery things may confuse
resume().

Also fixes the USB serial, HID and several usbnet drivers
which may recover device in suspend failure path of system sleep.

v2:
	- improve comments on suspend callback as suggested by Alan
	- update kerneldoc for usb_suspend_both as suggested by Alan
	- remove previous check of PMSG_IS_AUTO(message) in cdc_mbim/
	qmi_wwan and add comments on suspend failure case, since Bj=C3=B8rn
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
 drivers/usb/serial/usb-serial.c |    3 ++-
 include/linux/usb.h             |    7 ++++++-
 8 files changed, 41 insertions(+), 16 deletions(-)


Thanks,
--
Ming Lei

--
To unsubscribe from this list: send the line "unsubscribe linux-input" =
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
