From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 01/17] Doc: hisi: hns adds mc-mac-mask property
Date: Wed, 9 Nov 2016 18:13:45 +0000
Message-ID: <20161109181401.913728-2-salil.mehta@huawei.com>
References: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Kejian Yan <yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161109181401.913728-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

Since there is not enough tcam table entries for every vlan and multicast
address, HNS needs to add support of fuzzy matching of TCAM tables. Adding
the property to mask the bits to be fuzzy matched, so update the bindings
document

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
index d4b7f2e..abfbeec 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
@@ -45,6 +45,12 @@ Required properties:
   depends on the hardware user manual.
 - port-mode-offset: is offset of port mode field for each port in dsaf. Its
   value depends on the hardware user manual.
+- mc-mac-mask: mask of multicast address, determines bit in multicast address
+  to set:
+  1 stands for this bit will be precisely matched, TCAM will check this bit of
+    MAC address.
+  0 stands for this bit will be fuzzy matched, TCAM won't care about this bit
+    of MAC address.
 
 [1] Documentation/devicetree/bindings/net/phy.txt
 
@@ -74,10 +80,12 @@ dsaf0: dsa@c7000000 {
 		reg = 0;
 		phy-handle = <&phy0>;
 		serdes-syscon = <&serdes>;
+		mc-mac-mask = [ff f0 00 00 00 00];
 	};
 
 	port@1 {
                 reg = 1;
                 serdes-syscon = <&serdes>;
+		mc-mac-mask = [ff f0 00 00 00 00];
         };
 };
-- 
1.7.9.5
