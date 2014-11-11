From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH v2] usbnet: smsc95xx: dereferencing NULL pointer
Date: Tue, 11 Nov 2014 14:10:47 +0530
Message-ID: <1415695247-30442-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

we were dereferencing dev to initialize pdata. but just after that we
have a BUG_ON(!dev). so we were basically dereferencing the pointer
first and then tesing it for NULL.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---

change in v2: suspend_flags is initialised after pdata is initialised.
v1 had a very silly but serious mistake of making pdata NULL, and trying
to dereference it.
sorry again for that.

 drivers/net/usb/smsc95xx.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index d07bf4c..26423ad 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1670,12 +1670,14 @@ done:
 static int smsc95xx_resume(struct usb_interface *intf)
 {
 	struct usbnet *dev = usb_get_intfdata(intf);
-	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
-	u8 suspend_flags = pdata->suspend_flags;
+	struct smsc95xx_priv *pdata;
+	u8 suspend_flags;
 	int ret;
 	u32 val;
 
 	BUG_ON(!dev);
+	pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	suspend_flags = pdata->suspend_flags;
 
 	netdev_dbg(dev->net, "resume suspend_flags=0x%02x\n", suspend_flags);
 
-- 
1.8.1.2
