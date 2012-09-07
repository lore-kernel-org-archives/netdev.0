From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Subject: Endianess bug fix for sierra_net
Date: Fri, 7 Sep 2012 18:14:02 -0400
Message-ID: <20120907221402.GJ15650@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?utf-8?B?QmrDuHJu?= Mork <bjorn@mork.no>,
	Len Sorensen <lsorense@csclub.uwaterloo.ca>,
	linux@sierrawireless.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I discovered I couldn't get sierra_net to work on a powerpc.  Turns out
the firmware attribute check assumes the system is little endian and
hence fails because the attributes is a 16 bit value.

Signed-off-by: Len Sorensen <lsorense@csclub.uwaterloo.ca>

diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index 7be49ea..8e22417 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -656,7 +656,7 @@ static int sierra_net_get_fw_attr(struct usbnet *dev, u16 *datap)
 		return -EIO;
 	}
 
-	*datap = *attrdata;
+	*datap = le16_to_cpu(*attrdata);
 
 	kfree(attrdata);
 	return result;
