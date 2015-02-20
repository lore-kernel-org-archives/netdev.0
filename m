From: sfeldma@gmail.com
Subject: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB ageing in SW or HW
Date: Thu, 19 Feb 2015 23:09:50 -0800
Message-ID: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, gospo@cumulusnetworks.com,
	vbandaru@broadcom.com, siva.mannem.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:43090 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbbBTHJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 02:09:28 -0500
Received: by pdev10 with SMTP id v10so5650067pde.10
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 23:09:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add a new NTF_EXT_FLAG to mark an FDB as externally aged, for example by
offload hardware.   Switchdev driver/devices can set this flag when learning a
new FDB entry and SW (the bridge driver) will skip this entry when running its
ageing task.  If flag is set, the driver/device is responsible for calling
call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_DEL, ...) when entry expires.

This give the flexibility for driver/device to decide ageing policy based on
its capabilities.  For devices managing many FDB entries, it is desireable for
the device to aged out its own entries.  Devices not capable of aged entries
can rely of SW to age out the entries.

Scott Feldman (5):
  neighbour: add external aged flag
  switchdev: add ntf_flags to FDB notifier
  bridge: call external learn add if adding FDB entry with
    NTF_EXT_LEARNED set
  bridge: let HW control FDB ageing by setting NTF_EXT_AGED
  rocker: explicitly set SW ageing for rocker

 drivers/net/ethernet/rocker/rocker.c |    9 +++++----
 include/net/switchdev.h              |    1 +
 include/uapi/linux/neighbour.h       |    1 +
 net/bridge/br.c                      |   18 ++++++++++--------
 net/bridge/br_fdb.c                  |   16 +++++++++++++---
 net/bridge/br_private.h              |    8 +++++---
 6 files changed, 35 insertions(+), 18 deletions(-)

-- 
1.7.10.4
