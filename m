From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v2 0/2] r8152: device reset
Date: Tue, 28 Jul 2015 20:08:40 +0800
Message-ID: <1394712342-15778-159-Taiwan-albertk@realtek.com>
References: <1394712342-15778-156-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-156-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v2:
For patch #1, remove usb_autopm_get_interface(), usb_autopm_put_interface(), and
the checking of intf->condition.

For patch #2, replace the original method with usb_queue_reset_device() to reset
the device. 

v1:
Although the driver works normally, we find the device may get all 0xff data when
transmitting packets on certain platforms. It would break the device and no packet
could be transmitted. The reset is necessary to recover the hw for this situation.

Hayes Wang (2):
  r8152: add pre_reset and post_reset
  r8152: reset device when tx timeout

 drivers/net/usb/r8152.c | 90 ++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 86 insertions(+), 4 deletions(-)

-- 
2.4.2
