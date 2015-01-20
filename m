From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH 00/11] hso: fix some problems with reset/disconnect path
Date: Tue, 20 Jan 2015 13:29:27 +0100
Message-ID: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches attempt to fix some problems I observed when the hso
device is disconnected or when a usb reset is queued by the hso driver
Several patches of this serie are fixing crashes or memleaks in hso.
The last patch of this serie fix a race condition occurring when multiple
usb resets are queued on an usb interface.
This serie of patches is based on v3.18.

Olivier Sobrie (11):
  hso: remove useless header file timer.h
  hso: fix crash when device disappears while serial port is open
  hso: fix memory leak when device disconnects
  hso: fix memory leak in hso_create_rfkill()
  hso: fix small indentation error
  hso: rename hso_dev into serial in hso_free_interface()
  hso: replace reset_device work by usb_queue_reset_device()
  hso: move tty_unregister outside hso_serial_common_free()
  hso: update serial_table in usb disconnect method
  hso: add missing cancel_work_sync in disconnect()
  usb: core: fix a race with usb_queue_reset_device()

 drivers/net/usb/hso.c      | 88 ++++++++++++++++++++--------------------------
 drivers/usb/core/driver.c  |  4 ++-
 drivers/usb/core/hub.c     |  4 +--
 drivers/usb/core/message.c |  4 +--
 include/linux/usb.h        |  2 +-
 5 files changed, 46 insertions(+), 56 deletions(-)

-- 
2.2.0
