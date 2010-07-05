From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH v2 0/9]  atm:  propagate atm_dev signal carrier to LOWER_UP of netdevice
Date: Mon,  5 Jul 2010 10:45:52 +0200
Message-ID: <1278319561-23548-1-git-send-email-karl@hiramoto.org>
Cc: nathan@traverse.com.au, Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:41922 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042Ab0GEIqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 04:46:54 -0400
Received: from homiemail-a30.g.dreamhost.com (caiajhbdcbhh.dreamhost.com [208.97.132.177])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 7514A17A217
	for <netdev@vger.kernel.org>; Mon,  5 Jul 2010 01:46:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from v1:
Use atm_dev notifier chain  instead of callback function pointer in struct vcc.
In drivers/usb/atm call atm_dev_signal_change().

In userspace it's helpfull to know if a network device has a carrier signal. 
Often it is monitored via netlink.  This patchset allows a way for the 
struct atm_dev drivers to pass carrier on/off to the netdevice.

For DSL, carrier is on when the line has reached showtime state.

Currently this patchset only propagates the changes to br2684 vccs,
as this is the only type of hardware I have to test.

If you prefer git you can pull from:
git://github.com/karlhiramoto/linux-2.6.git atm-v2



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
 include/linux/atmdev.h       |   12 +++++++
 net/atm/br2684.c             |   66 ++++++++++++++++++++++++++++++++++++++++-
 net/atm/common.c             |   31 +++++++++++++++++++
 10 files changed, 182 insertions(+), 29 deletions(-)

