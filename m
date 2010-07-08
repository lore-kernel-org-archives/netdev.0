From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH v4 0/9] atm:  propagate atm_dev signal carrier to LOWER_UP of netdevice
Date: Thu,  8 Jul 2010 10:34:46 +0200
Message-ID: <1278578095-25324-1-git-send-email-karl@hiramoto.org>
Cc: Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcagg.dreamhost.com ([208.97.132.66]:57451 "EHLO
	homiemail-a36.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754964Ab0GHIfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 04:35:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Changes from v3:
* read_lock_irqsave() instead of read_lock_irq()
* format comments in atmdev.h

Changes from v2:
* use atomic instead of blocking notifier
* use read_lock_irq() instead of read_lock() in atm/br2684
* clean up comments
* remove unused variable.

Changes from v1:
Use atm_dev notifier chain  instead of callback function pointer in struct vcc.
In drivers/usb/atm call atm_dev_signal_change().

In userspace it's helpful to know if a network device has a carrier signal.
Often it is monitored via netlink.  This patchset allows a way for the
struct atm_dev drivers to pass carrier on/off to the netdevice.

For DSL, carrier is on when the line has reached showtime state.

Currently this patchset only propagates the changes to br2684 vccs,
as this is the only type of hardware I have to test.

If you prefer git you can pull from:
git://github.com/karlhiramoto/linux-2.6.git atm-v4


Karl Hiramoto (9):
  atm: propagate signal changes via notifier
  atm/br2684: register notifier event for carrier signal changes.
  atm/adummy: add syfs DEVICE_ATTR to change signal
  atm/idt77105.c: call atm_dev_signal_change() when signal changes.
  atm/solos-pci: call atm_dev_signal_change() when signal changes.
  atm/suni.c: call atm_dev_signal_change() when signal changes.
  usb/atm/cxacru.c: call atm_dev_signal_change() when signal changes.
  usb/atm/speedtch.c: call atm_dev_signal_change() when signal changes.
  usb/atm/ueagle-atm.c: call atm_dev_signal_change() when signal
    changes.

 drivers/atm/adummy.c         |   39 ++++++++++++++++++++++++
 drivers/atm/idt77105.c       |   11 ++++---
 drivers/atm/solos-pci.c      |    6 ++--
 drivers/atm/suni.c           |    5 ++-
 drivers/usb/atm/cxacru.c     |   18 ++++++------
 drivers/usb/atm/speedtch.c   |   10 +++---
 drivers/usb/atm/ueagle-atm.c |   13 ++++++--
 include/linux/atmdev.h       |   20 ++++++++++++
 net/atm/br2684.c             |   66 ++++++++++++++++++++++++++++++++++++++++-
 net/atm/common.c             |   30 +++++++++++++++++++
 10 files changed, 189 insertions(+), 29 deletions(-)

