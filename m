From: sfeldma@gmail.com
Subject: [PATCH net-next v2 0/7] bridge: don't age out externally added FDB entries
Date: Sun, 20 Sep 2015 08:48:22 -0700
Message-ID: <1442764109-11110-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35776 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbbITPpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 11:45:41 -0400
Received: by pacfv12 with SMTP id fv12so95507079pac.2
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 08:45:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

v2: Per Jiri review comment: add BR_DEFAULT_AGEING_TIME to defines

Siva originally proposed skipping externally added FDB entries in the bridge's
FDB garbage collection func, and moving the ageing of externally added entries
to the port driver/device.  This broke rocker, since rocker didn't have a
hardware (or software) mechanism for ageing out its learned FDB entries.

This patchset reintroduces Siva's bridge driver patch to skip externally added
entries and adds support in rocker so rocker can age out its own entries.
Rocker does this using a software timer similar to the bridge's FDB garbage
collection timer.  Other switchdev devices/drivers can use this software timer
method or program the device to nofity aged-out entries to the driver.

Updated switchdev.txt documentation to reflect current state-of-the-art.  This
removes one more XXX todo comment in switchdev.txt.

Scott Feldman (6):
  rocker: track when FDB entry is touched.
  rocker: store rocker_port in fdb key rather than pport
  bridge: define some min/max/default ageing time constants
  rocker: adding port ageing_time for ageing out FDB entries
  rocker: add FDB cleanup timer
  switchdev: update documentation on FDB ageing_time

Siva Mannem (1):
  bridge: don't age externally added FDB entries

 Documentation/networking/switchdev.txt |   24 +++++------
 drivers/net/ethernet/rocker/rocker.c   |   69 +++++++++++++++++++++++++++-----
 include/linux/if_bridge.h              |    6 +++
 net/bridge/br_device.c                 |    2 +-
 net/bridge/br_fdb.c                    |    2 +
 5 files changed, 80 insertions(+), 23 deletions(-)

-- 
1.7.10.4
