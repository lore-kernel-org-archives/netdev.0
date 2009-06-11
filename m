From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 16/21] wimax/i2400m: don't reset device when bootrom init retries are exceeded
Date: Thu, 11 Jun 2009 14:35:53 -0700
Message-ID: <6e053d6c79b3c1c9f6efc6563a811023c41be86a.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28457 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755710AbZFKVgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:46 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When i2400m_bootrom_init() fails to put the device into a state of
being ready to accept firmware, the driver was currently trying to
reset it if it failed to do so. This is not too useful; as part of
trying to put the device in the right state a few resets have already
been tried.

At this point, things are probably fried out and an extra reset might
do more harm than good (for example causing reseting of other
functions in the same composite device).

So it is left up to the callers to determine the error path to take
(at the end this is always i2400m_setup(), who depending on how many
retries are left, might give up on the device).

>From a fix by Cindy H. Kao.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 349344a..e81750e 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -696,8 +696,7 @@ error_dev_gone:
 	return result;
 
 error_timeout:
-	dev_err(dev, "Timed out waiting for reboot ack, resetting\n");
-	i2400m->bus_reset(i2400m, I2400M_RT_BUS);
+	dev_err(dev, "Timed out waiting for reboot ack\n");
 	result = -ETIMEDOUT;
 	goto exit_timeout;
 }
-- 
1.6.2.3

