From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH 0/6] atm:  propagate atm_dev signal carrier to LOWER_UP of netdevice
Date: Fri,  2 Jul 2010 19:47:04 +0200
Message-ID: <1278092830-10473-1-git-send-email-karl@hiramoto.org>
Cc: nathan@traverse.com.au, Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:52198 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756743Ab0GBRsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 13:48:16 -0400
Received: from homiemail-a32.g.dreamhost.com (caiajhbdcagg.dreamhost.com [208.97.132.66])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 9D4CD179504
	for <netdev@vger.kernel.org>; Fri,  2 Jul 2010 10:48:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In userspace it's helpfull to know if a network device has a carrier signal. 
Often it is monitored via netlink.  This patchset allows a way for the 
struct atm_dev drivers to pass carrier on/off to the netdevice.

For DSL, carrier is on when the line has reached showtime state.

Currently this patchset only propagates the changes to br2684 vccs,
as this is the only type of hardware I have to test.

If you prefer git you can pull from:
git://github.com/karlhiramoto/linux-2.6.git linux-atm

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>

Karl Hiramoto (6):
  atm: add hooks to propagate signal changes to netdevice
  atm br2684: add callback for carrier signal changes.
  atm/idt77105.c: call atm_dev_signal_change() when signal changes.
  atm/solos-pci: call atm_dev_signal_change() when signal changes.
  atm/suni.c: call atm_dev_signal_change() when signal changes.
  atm/adummy: add syfs DEVICE_ATTR to change signal

 drivers/atm/adummy.c    |   39 +++++++++++++++++++++++++++++++++++++++
 drivers/atm/idt77105.c  |   11 ++++++-----
 drivers/atm/solos-pci.c |    6 +++---
 drivers/atm/suni.c      |    5 +++--
 include/linux/atmdev.h  |    5 +++++
 net/atm/br2684.c        |   13 +++++++++++++
 net/atm/common.c        |   33 +++++++++++++++++++++++++++++++++
 7 files changed, 102 insertions(+), 10 deletions(-)

