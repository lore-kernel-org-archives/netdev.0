From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH v2 0/4] PTP attribute handling cleanup
Date: Tue, 14 Feb 2017 10:23:30 -0800
Message-ID: <20170214182334.23296-1-dmitry.torokhov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PTP core was creating some attributes, such as "period" and "fifo", and the
entire "pins" attribute group, after creating class deevice, which creates
a race for userspace: uevent may arrive before all attributes are created.

This series of patches switches PTP to use is_visible() to control
visibility of attributes in a group, and device_create_with_groups() to
ensure that attributes are created before we notify userspace of a new
device.

v2:
- added Richard's acked-by to patch #1
- removed use of kmalloc_array in favor of kcalloc in patch #2 at
  Richard's request
- added a cover letter

v1:
- initial patch set

Dmitry Torokhov (4):
  ptp: do not explicitly set drvdata in ptp_clock_register()
  ptp: use kcalloc when allocating arrays
  ptp: use is_visible method to hide unused attributes
  ptp: create "pins" together with the rest of attributes

 drivers/ptp/ptp_clock.c   |  22 +++---
 drivers/ptp/ptp_private.h |   7 +-
 drivers/ptp/ptp_sysfs.c   | 167 ++++++++++++++++++----------------------------
 3 files changed, 80 insertions(+), 116 deletions(-)

Thanks.

-- 
Dmitry
