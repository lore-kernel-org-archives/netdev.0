From: Kalle Valo <kvalo@adurom.com>
Subject: [PATCH v3 0/2] Fix uevent race in register_netdevice()
Date: Mon, 16 May 2011 17:46:30 +0300
Message-ID: <20110516143913.13838.85357.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh07.mail.saunalahti.fi ([62.142.5.117]:48991 "EHLO
	emh07.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755865Ab1EPOqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 10:46:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to fix a race in register_netdevice(). The problem is that
there's a uevent to userspace before the netdevice is ready for use. The
problem is described here:

https://bugzilla.kernel.org/show_bug.cgi?id=15606

I have sent few different ways to fix this, but none of them have been
really usable. Now I came up with a way which changes the driver core
to make it possible send the uevent in a separate call. This is a clean
and safe way to fix the race. Downside is that two new functions are
added to the driver core interface.

Please comment.

---

Kalle Valo (2):
      driver core: add device_add_noevent() and device_uevent()
      net: postpone net device uevent to fix a race


 drivers/base/core.c    |   76 +++++++++++++++++++++++++++++++++++++-----------
 include/linux/device.h |    2 +
 net/core/dev.c         |    3 ++
 net/core/net-sysfs.c   |    2 +
 4 files changed, 65 insertions(+), 18 deletions(-)

