From: Yisen Zhuang <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 net-next 12/13] Documentation: Bindings: add port-idx-in-ae for enet node
Date: Sat, 23 Apr 2016 17:05:16 +0800
Message-ID: <1461402317-136499-13-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xieqianqian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461402317-136499-1-git-send-email-Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds description for port-idx-in-ae attribute.

Signed-off-by: Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 .../devicetree/bindings/net/hisilicon-hns-nic.txt  | 30 +++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
index e6a9d1c..b9ff4ba 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
@@ -36,6 +36,34 @@ Required properties:
                        | | | | | |
                       external port
 
+  This attribute is remained for compatible purpose. It is not recommended to
+  use it in new code.
+
+- port-idx-in-ae: is the index of port provided by AE.
+  In NIC mode of DSAF, all 6 PHYs of service DSAF are taken as ethernet ports
+  to the CPU. The port-idx-in-ae can be 0 to 5. Here is the diagram:
+            +-----+---------------+
+            |            CPU      |
+            +-+-+-+---+-+-+-+-+-+-+
+              |    |   | | | | | |
+           debug debug   service
+           port  port     port
+           (0)   (0)     (0-5)
+
+  In Switch mode of DSAF, all 6 PHYs of service DSAF are taken as physical
+  ports connected to a LAN Switch while the CPU side assume itself have one
+  single NIC connected to this switch. In this case, the port-idx-in-ae
+  will be 0 only.
+            +-----+-----+------+------+
+            |                CPU      |
+            +-+-+-+-+-+-+-+-+-+-+-+-+-+
+              |    |     service| port(0)
+            debug debug  +------------+
+            port  port   |   switch   |
+            (0)   (0)    +-+-+-+-+-+-++
+                          | | | | | |
+                         external port
+
 - local-mac-address: mac addr of the ethernet interface
 
 Example:
@@ -43,6 +71,6 @@ Example:
 	ethernet@0{
 		compatible = "hisilicon,hns-nic-v1";
 		ae-handle = <&dsaf0>;
-		port-id = <0>;
+		port-idx-in-ae = <0>;
 		local-mac-address = [a2 14 e4 4b 56 76];
 	};
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
