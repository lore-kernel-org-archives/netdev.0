From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/4 12/13] wimax/i2400m: Let device's status reports change the device state
Date: Wed,  4 Nov 2009 13:40:07 -0800
Message-ID: <0c96859d7a5f0286ed70d3c4e140ac6816a350da.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:17987 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932750AbZKDVmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:13 -0500
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently __i2400m_dev_start was forcing, after uploading firmware and
doing a few checks to WIMAX_ST_UNINITIALIZED.

This can be overriding state changes that the device might have caused
by sending reports; thus it makes more sense to remove it and let the
device update the status on its own by sending reports.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 42102eb..cc900b9 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -398,7 +398,6 @@ retry:
 	result = i2400m_check_mac_addr(i2400m);
 	if (result < 0)
 		goto error_check_mac_addr;
-	wimax_state_change(wimax_dev, WIMAX_ST_UNINITIALIZED);
 	result = i2400m_dev_initialize(i2400m);
 	if (result < 0)
 		goto error_dev_initialize;
-- 
1.6.2.5

