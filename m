From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH 00/14] RFC: Driver for Wireless RNDIS USB devices.
Date: Sun, 20 Jan 2008 02:13:42 +0200
Message-ID: <20080120001342.25718.83669.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bjd@jooz.net, dbrownell@users.sourceforge.net,
	netdev@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn2.hy.skanova.net ([81.228.8.154]:49048 "EHLO
	pne-smtpout4-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751785AbYATANt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2008 19:13:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This is second try on wireless RNDIS patchset started by Bjorge Dijkstra. Since
Bjorge has disappeared, I claim maintainership of rndis_wext and this patchset
until he returns.

This patchset adds support for various 802.11 USB devices based on Broadcom
4320 chip. Chip uses RNDIS to communicate with the host, so module depend
heavily on rndis_host/cdc_ether/usbnet and needs some changes on these 
modules in order to work.

Patches 1-6 are from first patchset:
 1. Fix sparse warning: returning void valued expression
 2. [cdc_ether] Hardwire CDC descriptors when missing
 3. [rndis_host] Use 1KB buffer in rndis_unbind
 4. [rndis_host] Halt device if rndis_bind fails
 5. [rndis_host] Fix rndis packet filter flags
 6. [usbnet] Use wlan device name for RNDIS wireless devices

Of these 1, 3 and 4 are not required for this version of rndis_wext to work.

Actual wireless part is changed from extension on rndis_host to separate 
driver. Different devices are detected by device specific USB vendor/product 
IDs as the way done with Windows drivers instead of detecting RNDIS media type 
like in first patchset.

New patches 7-14:
 7. [rndis_host] Split up rndis_host.c
 8. [rndis_host] export functions
 9. [usbnet] add driver_priv pointer to 'struct usbnet'
10. [rndis_host] Add rndis_early_init function pointer to 'struct rndis_data'.
11. [rndis_host] Add rndis_link_change function pointer to 'struct rndis_data'.
12. Move usbnet.h and rndis_host.h to include/linux/usb
13. [rndis_host] blacklist known wireless RNDIS devices
14. Add new driver 'rndis_wext' for wireless RNDIS devices.

Patches should be applied in order, series apply cleanly to 2.6.24-rc8.

 - Jussi Kivilinna

