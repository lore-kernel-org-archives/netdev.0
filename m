From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 08/15] wimax/i2400m: workaround not-so-working %zd printf format
Date: Wed,  4 Nov 2009 13:39:49 -0800
Message-ID: <59bdc4be0b819173a8f840fc11ccb82d6f2ca64b.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20710 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932714AbZKDVmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:00 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel's %zd modifier does not really work. Use %ld (has to cast
ssize_t to long).

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/usb-fw.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/usb-fw.c b/drivers/net/wimax/i2400m/usb-fw.c
index f162c81..b59aee0 100644
--- a/drivers/net/wimax/i2400m/usb-fw.c
+++ b/drivers/net/wimax/i2400m/usb-fw.c
@@ -330,8 +330,8 @@ error_dev_gone:
 out:
 	if (do_autopm)
 		usb_autopm_put_interface(i2400mu->usb_iface);
-	d_fnend(8, dev, "(i2400m %p ack %p size %zu) = %zd\n",
-		i2400m, ack, ack_size, result);
+	d_fnend(8, dev, "(i2400m %p ack %p size %zu) = %ld\n",
+		i2400m, ack, ack_size, (long) result);
 	return result;
 
 error_exceeded:
-- 
1.6.2.5

