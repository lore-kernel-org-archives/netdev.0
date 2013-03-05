From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 5/7] usbnet: smsc95xx: don't recover device if suspend fails in system sleep
Date: Tue,  5 Mar 2013 12:01:41 +0800
Message-ID: <1362456103-24956-6-git-send-email-ming.lei@canonical.com>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org,
	Ming Lei <ming.lei@canonical.com>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If suspend callback fails in system sleep context, usb core will
ignore the failure and let system sleep go ahead further, so
this patch doesn't recover device under this situation.

Cc: Steve Glendinning <steve.glendinning@shawell.net>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/smsc95xx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index e6d2dea..a0c5478 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1660,7 +1660,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	ret = smsc95xx_enter_suspend0(dev);
 
 done:
-	if (ret)
+	if (ret && PMSG_IS_AUTO(msg))
 		usbnet_resume(intf);
 	return ret;
 }
-- 
1.7.9.5

