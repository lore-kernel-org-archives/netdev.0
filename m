From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 08/25] wimax/i2400m: Correct the error path handlers order in i2400m_post_reset()
Date: Fri, 14 May 2010 14:45:07 -0700
Message-ID: <2354161dd33b204d36caa0bc48c95cc6c1a984fb.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:52953 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757799Ab0ENVtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:11 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

When bus_setup fails in i2400m_post_reset(), it falls to the error path handler
"error_bus_setup:" which includes unlock the mutext. However, we didn't ever
try to the obtain the lock when running bus_setup.

The patch is to fix the misplaced error path handler "error_bus_setup:".

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
---
 drivers/net/wimax/i2400m/driver.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index d83fe84..39cf96a 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -629,12 +629,12 @@ int i2400m_post_reset(struct i2400m *i2400m)
 error_dev_start:
 	if (i2400m->bus_release)
 		i2400m->bus_release(i2400m);
-error_bus_setup:
 	/* even if the device was up, it could not be recovered, so we
 	 * mark it as down. */
 	i2400m->updown = 0;
 	wmb();		/* see i2400m->updown's documentation  */
 	mutex_unlock(&i2400m->init_mutex);
+error_bus_setup:
 	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, result);
 	return result;
 }
-- 
1.6.6.1

