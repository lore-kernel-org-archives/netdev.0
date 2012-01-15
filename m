From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH v2 0/3] Adding new drivers for Qualcomm MSM based LTE modems
Date: Sun, 15 Jan 2012 07:40:34 +0100
Message-ID: <cover.1326607234.git.bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

patch 1 relaxes the cdc_ether CDC descriptor parsing in such a way
that it will allow a vendor specific data interface if and only if
the control interface also is vendor specific.  This allows us to
reuse the bind() function from cdc_ether for one of the possible
device configurations we support

patch 2 adds a new "subdriver" which exports the CDC encapsulated=20
command interface as a character device, and also to the calling
driver.

patch 3 adds the wwan driver, which uses the "subdriver" to configure
the device via the Qualcomm MSM Interface (QMI) protocol encapsulated
in CDC control commands. The actual network device is a minimalistic
usbnet minidriver.



Bj=C3=B8rn Mork (3):
  cdc_ether: allow vendor specific data interface if control interface
    is vendor specific
  net: usb: cdc_enc: New driver exposing USB CDC encapsulated protocols
  net: usb: qmi_wwan: New driver for QMI WAN devices

 drivers/net/usb/Kconfig         |   28 +++
 drivers/net/usb/Makefile        |    3 +
 drivers/net/usb/cdc_enc.c       |  452 +++++++++++++++++++++++++++++++=
++++++
 drivers/net/usb/cdc_enc.h       |   77 +++++++
 drivers/net/usb/cdc_ether.c     |    6 +-
 drivers/net/usb/qmi_proto.c     |  475 +++++++++++++++++++++++++++++++=
++++++++
 drivers/net/usb/qmi_proto.h     |   98 ++++++++
 drivers/net/usb/qmi_wwan_core.c |  343 ++++++++++++++++++++++++++++
 8 files changed, 1481 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/usb/cdc_enc.c
 create mode 100644 drivers/net/usb/cdc_enc.h
 create mode 100644 drivers/net/usb/qmi_proto.c
 create mode 100644 drivers/net/usb/qmi_proto.h
 create mode 100644 drivers/net/usb/qmi_wwan_core.c

--=20
1.7.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
