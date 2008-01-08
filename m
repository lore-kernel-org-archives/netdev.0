From: Russ Dill <Russ.Dill@asu.edu>
Subject: [NET] mcs7830 passes msecs instead of jiffies to usb_control_msg
Date: Tue, 08 Jan 2008 00:09:39 -0700
Message-ID: <1199776179.26870.1.camel@russ-laptop>
References: <134b1d6c0801071520h9932537ke0b5daeaabab289b@mail.gmail.com>
	 <20080107.214826.153054474.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from epo-int1.asu.edu ([129.219.187.20]:52271 "EHLO epo-int1.asu.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751018AbYAHH1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 02:27:47 -0500
In-Reply-To: <20080107.214826.153054474.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usb_control_msg was changed long ago (2.6.12-pre) to take milliseconds
instead of jiffies. Oddly, mcs7830 wasn't added until 2.6.19-rc3.

Signed-off-by: Russ Dill <Russ.Dill@asu.edu>
---
 drivers/net/usb/mcs7830.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index f55a595..5ea7411 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -94,7 +94,7 @@ static int mcs7830_get_reg(struct usbnet *dev, u16 index, u16 size, void *data)
 
 	ret = usb_control_msg(xdev, usb_rcvctrlpipe(xdev, 0), MCS7830_RD_BREQ,
 			      MCS7830_RD_BMREQ, 0x0000, index, data,
-			      size, msecs_to_jiffies(MCS7830_CTRL_TIMEOUT));
+			      size, MCS7830_CTRL_TIMEOUT);
 	return ret;
 }
 
@@ -105,7 +105,7 @@ static int mcs7830_set_reg(struct usbnet *dev, u16 index, u16 size, void *data)
 
 	ret = usb_control_msg(xdev, usb_sndctrlpipe(xdev, 0), MCS7830_WR_BREQ,
 			      MCS7830_WR_BMREQ, 0x0000, index, data,
-			      size, msecs_to_jiffies(MCS7830_CTRL_TIMEOUT));
+			      size, MCS7830_CTRL_TIMEOUT);
 	return ret;
 }
 
-- 
1.5.3.7



