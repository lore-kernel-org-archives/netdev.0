From: Toby Gray <toby.gray@realvnc.com>
Subject: [PATCH 0/5] Delay selecting alternate setting in CDC NCM until network interface is raised
Date: Wed, 15 Feb 2012 14:47:36 +0000
Message-ID: <1329317261-3406-1-git-send-email-toby.gray@realvnc.com>
Cc: netdev@vger.kernel.org, alexey.orishko@gmail.com,
	Toby Gray <toby.gray@realvnc.com>
To: Toby Gray <tg@realvnc.com>, Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from realvnc.com ([146.101.152.142]:53042 "EHLO realvnc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759354Ab2BOOsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 09:48:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series moves the setting of the alternate setting used
for the CDC NCM data interface until the network interface is
raised. Before this patch series the CDC NCM driver would select
the alternate setting which allows data to be sent and received
as soon as the device was probed.

While the previous behaviour was not against the CDC NCM
specification it is problematic with some CDC NCM devices,
e.g. Nokia 701 Mobile Telephone. These devices will only send the
network connection status notification to the host if the control
interrupt endpoint is read from within a few seconds of the data
enabled alternate setting being selected.

This behaviour means that the network connection notification
would never be received and so the network interface would stay
in a disconnected state indefinitely, unless the interface was
marked as 'up' almost immediately after the CDC NCM device was
probed.

Toby Gray (5):
  usb: cdc-ncm: Change alternate setting magic numbers into #defines
  usb: cdc-ncm: Set altsetting only when network interface is opened
  usb: usbnet: Allow drivers using usbnet to specify maximum packet
    size
  usb: usbnet: Add validation of dev->maxpacket to usbnet
  usb: cdc-ncm: Allow NCM driver to determine dev->maxpacket

 drivers/net/usb/cdc_ncm.c |   46 ++++++++++++++++++++++++++++++++++++--------
 drivers/net/usb/usbnet.c  |    7 +++++-
 2 files changed, 43 insertions(+), 10 deletions(-)
