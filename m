From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Gigabit ethernet driver for Alacritechs SLIC devices (v4)
Date: Mon,  5 Dec 2016 23:07:15 +0100
Message-ID: <1480975637-18245-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: andrew@lunn.ch, roszenrami@gmail.com, markus.boehme@mailbox.org,
        f.fainelli@gmail.com, devel@driverdev.osuosl.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, charrer@alacritech.com, liodot@gmail.com,
        gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this is the forth version of the slicoss gigabit ethernet driver (which is a
rework of the driver from Alacritech which can currently be found under
drivers/staging/slicoss). The driver is supposed to support Mojave, Oasis and
Kalahari cards, for both copper and fiber.

If this code is accepted the staging version can be removed.

The driver has been tested on a SEN2104ET adapter (4 Port PCIe copper).

v4:
- fix wrong driver name in Kconfig file (reported by Rami Rosen)
- remove unused variable from driver struct (reported by Rami Rosen)
- return "err" instead of 0 in slic_load_rcvseq_firmware() (reported by Rami Rosen)
- Fix typos in constants, comments and error message (reported by Markus Böhme)
- fix various warnings concerning signedness (reported by Markus Böhme)
- improve line formatting (reported by Markus Böhme)
- add comment describing the need for SLIC_MAX_TX_COMPLETIONS (suggested by Florian Fainelli)
- do not zero out complete rx descriptor (suggested by Florian Fainelli)
- add missing write barrier (reported by Florian Fainelli)
- remove unneeded assignment of net_device to skb (reported by Florian Fainelli)
- use napi_complete_done() instead of napi_complete (suggested by Florian Fainelli)
- use napi_schedule_irqoff() instead of napi_schedule (suggested by Florian Fainelli)
- do not map error returned by slic_init() to -ENOMEM
- do proper dma syncs before and after rx descriptor status is set to 0
- if after dma sync for CPU rx descriptor is not used return it to HW by means of dma sync for device

v3:
- dont add defines to pci_ids.h but instead put it into the drivers header file
(requested by Greg Kroah-Hartman)

v2:
- remove unusual padding in statistic strings (suggested by Andrew Lunn)
- for mdio register and bit names use defines from mii.h instead of own ones
  (suggested by Andrew Lunn)
- remove unused defines
- ensure PCI flush at two more places
- use mmiowb before lock to prevent mmio writes leaking out of lock
- fix some typos in comments
- add copyright and GPL header

Regards,
Lino 
