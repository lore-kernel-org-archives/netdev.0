From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH V5 net-next 0/3] The huawei_cdc_ncm driver
Date: Mon, 30 Sep 2013 04:50:06 +0000
Message-ID: <1380516609-31242-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Robert de Vries <rhdv@xs4all.nl>,
	Hayes Wang <hayeswang@realtek.com>,
	Freddy Xin <freddy@asix.com.tw>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Liu Junliang <liujunliang_ljl@163.com>,
	linux-kernel@vger.kernel.org (open list),
	linux-usb@vger.kernel.org (open list:USB NETWORKING DR...),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	ModemManager-devel@lists.freedesktop.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So this is a new, revised, edition of the huawei_cdc_ncm.c driver, which 
supports devices resembling the NCM standard, but using it also as a mean 
to encapsulate other protocols, as is the case for the Huawei E3131 and
E3251 modem devices.
Some precisations are needed however - and I encourage discussion on this: and 
that's why I'm sending this message with a broader CC.
Merging those patches might change:
- the way Modem Manager interacts with those devices
- some regressions might be possible if there are some unknown firmware 
  variants around (Franko?)

First of all: I observed the behaviours of two devices.
Huawei E3131: this device doesn't accept NDIS setup requests unless they're 
sent via the embedded AT channel exposed by this driver.
So actually we gain funcionality in this case!

The second case, is the Huawei E3251: which works with standard NCM driver, 
still exposing an AT embedded channel. Whith this patch set applied, you gain 
some funcionality, loosing the ability to catch standard NCM events for now.
The device will work in both ways with no problems, but this has to be 
acknowledged and discussed. Might be we can develop this driver further to 
change this, when more devices are tested.

We where thinking Huawei changed their interfaces on new devices - but probably 
this driver only works around a nice firmware bug present in E3131, which 
prevented the modem from being used in NDIS mode.

I think committing this is definitely wortth-while, since it will allow for 
more Huawei devices to be used without serial connection. Some devices like the 
E3251 also, reports some status information only via the embedded AT channel, 
at least in my case.
Note: I'm not subscribed to any list except the Modem Manager's one, so please 
CC me, thanks!!


Enrico Mioso (3):
  net: cdc_ncm: Export cdc_ncm_{tx,rx}_fixup functions for re-use
  net: huawei_cdc_ncm: Introduce the huawei_cdc_ncm driver
  net: cdc_ncm: remove non-standard NCM device IDs

 drivers/net/usb/Kconfig          |  15 +++
 drivers/net/usb/Makefile         |   1 +
 drivers/net/usb/cdc_ncm.c        |  17 +--
 drivers/net/usb/huawei_cdc_ncm.c | 228 +++++++++++++++++++++++++++++++++++++++
 include/linux/usb/cdc_ncm.h      |   3 +
 5 files changed, 251 insertions(+), 13 deletions(-)
 create mode 100644 drivers/net/usb/huawei_cdc_ncm.c

-- 
1.8.4
