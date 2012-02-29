From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next/usb-next v3 0/5] cdc-wdm/qmi_wwan: subdriver support
Date: Wed, 29 Feb 2012 16:15:02 +0100
Message-ID: <1330528507-16551-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, Oliver Neukum <oliver@neukum.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org
To: linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54272 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031096Ab2B2PQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 10:16:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set enables the cdc-wdm USB class driver to be used as a
subdriver, and updates the qmi_wwan usbnet minidriver to use this
new functionality.

The purpose is to support a number of 3G/LTE devices based on Qualcomm
chipsets providing a single USB interface combining usbnet and
Qualcomm Messaging Interface (QMI) protocol support.  The usbnet wwan
interface must be initialized via the QMI channel before it is usable.
This initialization is complex and depends on many user policy decision=
s.
By using the cdc-wdm driver to export the QMI interface as a character
device, all this complexity can be left to userspace applications.  Thi=
s
makes us able to support a large number of different devices with very
different capabilities using a single relatively simple driver.

The 2 previous revisions of this set were considered work-in-progress
and were therefore only posted to the linux-usb list for discussion, to
avoid having them end up unnecessarily in netdev patchworks.=20

Changes in v3:
 - move manage_power call in wdm_open() outside the section where we
   hold the wlock mutex
 - proper initialization of the pmcount counter
 - added all non-QDL Gobi device IDs from qcserial driver


Only patch 4 and 5 of this set applies to, and is crossposted to, netde=
v.

Note that the netdev patches still depend on the 3 first patches of thi=
s
set, and should not be applied independently. The 3 first do not yet
apply to net-next, as they depend on other patches in usb-next and
linux-next. Please let me know if this sort of cross-system
patch set should be handled otherwise.

All 5 patches are verified to apply cleanly to linux-next tag next-2012=
0229.
Patches 1-3 are verified to apply to usb-next commit aac1fc386
Patches 4-5 are verified to apply to net-next commit 9100eb012 , but wi=
ll
cause build errors there due to the lack of the required 3 first patche=
s
as noted above.


Bj=C3=B8rn Mork (5):
  usb: cdc-wdm: split out reusable parts of probe
  usb: cdc-wdm: adding list lookup indirection
  usb: cdc-wdm: adding usb_cdc_wdm_register subdriver support
  net: qmi_wwan: support devices having a shared QMI/wwan interface
  net: qmi_wwan: add Gobi and Pantech UML290 device IDs

 drivers/net/usb/qmi_wwan.c  |  248 +++++++++++++++++++++++++++++++++++=
+++++---
 drivers/usb/class/cdc-wdm.c |  224 +++++++++++++++++++++++++++--------=
---
 include/linux/usb/cdc-wdm.h |   19 ++++
 3 files changed, 410 insertions(+), 81 deletions(-)
 create mode 100644 include/linux/usb/cdc-wdm.h

--=20
1.7.9
