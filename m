From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 05/25] wimax/i2400m: correct the error path handlers in dev_start()
Date: Fri, 14 May 2010 14:45:04 -0700
Message-ID: <49d72df3f6cd63b49528306a2577ae7a6a0e9d6b.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:52149 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932399Ab0ENVtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:08 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

This fix is to correct order of the handlers in the error path
of dev_start(). When i2400m_firmware_check fails, all the works done
before it should be released or cleared.

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
---
 drivers/net/wimax/i2400m/driver.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 94dc83c..3a6c8dd 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -403,10 +403,10 @@ retry:
 
 error_dev_initialize:
 error_check_mac_addr:
+error_fw_check:
 	i2400m->ready = 0;
 	wmb();		/* see i2400m->ready's documentation  */
 	flush_workqueue(i2400m->work_queue);
-error_fw_check:
 	if (i2400m->bus_dev_stop)
 		i2400m->bus_dev_stop(i2400m);
 error_bus_dev_start:
-- 
1.6.6.1

