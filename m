From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: [PATCH 0/2] usbnet: Fix 2 problems in usbnet_stop()
Date: Mon, 24 Aug 2015 23:13:41 +0300
Message-ID: <1440447223-15945-1-git-send-email-eugene.shatokhin@rosalab.ru>
References: <55AD3A41.2040100@rosalab.ru>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55AD3A41.2040100@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following problems found when investigating races in usbnet module 
are fixed here:

1. EVENT_NO_RUNTIME_PM bit of dev->flags should be read before it is 
cleared by "dev->flags = 0". Thanks to Oliver Neukum for spotting this
problem and providing a fix.

2. A race on on skb_queue between usbnet_stop() and usbnet_bh().

Compared to the combined patch I sent earlier 
("[PATCH] usbnet: Fix two races between usbnet_stop() and the BH"), this 
patch set has the following changes:

* The fix for handling of EVENT_NO_RUNTIME_PM is now in a separate patch.
* The fix for the race on dev->flags has been removed because the race is
not considered harmful.

Regards,
Eugene
