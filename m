From: Bjorn Mork <bjorn@mork.no>
Subject: [PATCH 0/3] Adding a new driver for Huawei E392 WWAN modem
Date: Tue, 13 Dec 2011 05:33:01 +0100
Message-ID: <1323750784-32608-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57647 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752768Ab1LMEdO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Dec 2011 23:33:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=C3=B8rn Mork <bjorn@mork.no>

This can probably support many more devices based on modern Qualcomm
chipsets, but has only been tested with a Huawei E392 LTE modem based
on Qualcomm MDM9200.

These chips require using the QMI protocol to enable anything but
serial mode.  They can, and should, still be configured using=20
AT commands on one of the serial interfaces.  In particular, this
driver does not support entering SIM PIN code or APN, which may be
required before opening a connection. PIN can be set by using the
standard AT+CPIN=3D"xxxx" command.  APN can most likely be set by
storing it in the default profile.

patch 1 releases one of the interfaces used by this protocol from
the option driver. Note that this interface does not support serial
data anyway, so the option driver binding is completely bogus.

patch 2 relaxes the cdc_ether CDC descriptor parsing in such a way
that it will allow a vendor specific data interface if and only if
the control interface also is vendor specific.  This allows us to
reuse the bind() function from cdc_ether for one of the possible
device configurations we support

patch 3 adds the new driver.  Most of it is QMI protocol handling.
The network device is a minimalistic usbnet minidriver.



Bj=C3=B8rn Mork (3):
  option: Removing one bogus and adding some new Huawei combinations
  cdc_ether: allow vendor specific data interface if control interface
    is vendor specific
  qmi_wwan: Driver for WWAN devices requiring use of the QMI protocol

 drivers/net/usb/Kconfig         |   13 +
 drivers/net/usb/Makefile        |    2 +
 drivers/net/usb/cdc_ether.c     |    8 +-
 drivers/net/usb/qmi.c           |  730 +++++++++++++++++++++++++++++++=
++++++++
 drivers/net/usb/qmi.h           |  101 ++++++
 drivers/net/usb/qmi_wwan_core.c |  206 +++++++++++
 drivers/usb/serial/option.c     |    4 +-
 7 files changed, 1061 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/usb/qmi.c
 create mode 100644 drivers/net/usb/qmi.h
 create mode 100644 drivers/net/usb/qmi_wwan_core.c

--=20
1.7.7.3
