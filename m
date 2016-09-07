From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH] kaweth: remove obsolete debugging statements
Date: Wed,  7 Sep 2016 15:27:09 +0200
Message-ID: <1473254829-26438-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56595 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752699AbcIGNxq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 09:53:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SOme statements in the driver only served to inform
which functions were entered. Ftrace can do that just as good without
needing memory. Remove the statements.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/kaweth.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 528b9c9..66b34dd 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -265,8 +265,6 @@ static int kaweth_control(struct kaweth_device *kaweth,
 	struct usb_ctrlrequest *dr;
 	int retval;
 
-	netdev_dbg(kaweth->net, "kaweth_control()\n");
-
 	if(in_interrupt()) {
 		netdev_dbg(kaweth->net, "in_interrupt()\n");
 		return -EBUSY;
@@ -300,8 +298,6 @@ static int kaweth_read_configuration(struct kaweth_device *kaweth)
 {
 	int retval;
 
-	netdev_dbg(kaweth->net, "Reading kaweth configuration\n");
-
 	retval = kaweth_control(kaweth,
 				usb_rcvctrlpipe(kaweth->dev, 0),
 				KAWETH_COMMAND_GET_ETHERNET_DESC,
@@ -451,8 +447,6 @@ static int kaweth_trigger_firmware(struct kaweth_device *kaweth,
 	kaweth->firmware_buf[6] = 0x00;
 	kaweth->firmware_buf[7] = 0x00;
 
-	netdev_dbg(kaweth->net, "Triggering firmware\n");
-
 	return kaweth_control(kaweth,
 			      usb_sndctrlpipe(kaweth->dev, 0),
 			      KAWETH_COMMAND_SCAN,
@@ -471,7 +465,6 @@ static int kaweth_reset(struct kaweth_device *kaweth)
 {
 	int result;
 
-	netdev_dbg(kaweth->net, "kaweth_reset(%p)\n", kaweth);
 	result = usb_reset_configuration(kaweth->dev);
 	mdelay(10);
 
@@ -685,8 +678,6 @@ static int kaweth_open(struct net_device *net)
 	struct kaweth_device *kaweth = netdev_priv(net);
 	int res;
 
-	netdev_dbg(kaweth->net, "Opening network device.\n");
-
 	res = usb_autopm_get_interface(kaweth->intf);
 	if (res) {
 		dev_err(&kaweth->intf->dev, "Interface cannot be resumed.\n");
@@ -951,7 +942,6 @@ static int kaweth_suspend(struct usb_interface *intf, pm_message_t message)
 	struct kaweth_device *kaweth = usb_get_intfdata(intf);
 	unsigned long flags;
 
-	dev_dbg(&intf->dev, "Suspending device\n");
 	spin_lock_irqsave(&kaweth->device_lock, flags);
 	kaweth->status |= KAWETH_STATUS_SUSPENDING;
 	spin_unlock_irqrestore(&kaweth->device_lock, flags);
@@ -968,7 +958,6 @@ static int kaweth_resume(struct usb_interface *intf)
 	struct kaweth_device *kaweth = usb_get_intfdata(intf);
 	unsigned long flags;
 
-	dev_dbg(&intf->dev, "Resuming device\n");
 	spin_lock_irqsave(&kaweth->device_lock, flags);
 	kaweth->status &= ~KAWETH_STATUS_SUSPENDING;
 	spin_unlock_irqrestore(&kaweth->device_lock, flags);
@@ -1190,8 +1179,6 @@ err_fw:
 	dev_info(dev, "kaweth interface created at %s\n",
 		 kaweth->net->name);
 
-	dev_dbg(dev, "Kaweth probe returning.\n");
-
 	return 0;
 
 err_intfdata:
@@ -1219,8 +1206,6 @@ static void kaweth_disconnect(struct usb_interface *intf)
 	struct kaweth_device *kaweth = usb_get_intfdata(intf);
 	struct net_device *netdev;
 
-	dev_info(&intf->dev, "Unregistering\n");
-
 	usb_set_intfdata(intf, NULL);
 	if (!kaweth) {
 		dev_warn(&intf->dev, "unregistering non-existent device\n");
-- 
2.6.2
