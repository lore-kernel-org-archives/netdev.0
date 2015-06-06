From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] isdn/hisax: Convert use of __constant_cpu_to_le16 to
 cpu_to_le16
Date: Sat, 6 Jun 2015 06:44:00 +0530
Message-ID: <20150606011400.GA10287@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In big endian cases, macro cpu_to_le16 unfolds to __swab16 which
provides special case for constants. In little endian cases,
__constant_cpu_to_le16 and cpu_to_le16 expand directly to the
same expression. So, replace __constant_cpu_to_le16 with
cpu_to_le16 with the goal of getting rid of the definition of
__constant_cpu_to_le16 completely.

The semantic patch that performs this transformation is as follows:

@@expression x;@@

- __constant_cpu_to_le16(x)
+ cpu_to_le16(x)

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 drivers/isdn/hisax/st5481_usb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/st5481_usb.c b/drivers/isdn/hisax/st5481_usb.c
index ead0a4f..a0fdbc0 100644
--- a/drivers/isdn/hisax/st5481_usb.c
+++ b/drivers/isdn/hisax/st5481_usb.c
@@ -267,8 +267,8 @@ int st5481_setup_usb(struct st5481_adapter *adapter)
 	}
 
 	// The descriptor is wrong for some early samples of the ST5481 chip
-	altsetting->endpoint[3].desc.wMaxPacketSize = __constant_cpu_to_le16(32);
-	altsetting->endpoint[4].desc.wMaxPacketSize = __constant_cpu_to_le16(32);
+	altsetting->endpoint[3].desc.wMaxPacketSize = cpu_to_le16(32);
+	altsetting->endpoint[4].desc.wMaxPacketSize = cpu_to_le16(32);
 
 	// Use alternative setting 3 on interface 0 to have 2B+D
 	if ((status = usb_set_interface(dev, 0, 3)) < 0) {
-- 
1.9.1
