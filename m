From: "Wei Hu(Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/4] infiniband: hns: add Hisilicon RoCE support(binding)
Date: Fri, 4 Mar 2016 16:41:15 +0800
Message-ID: <1457080877-13456-3-git-send-email-xavier.huwei@huawei.com>
References: <1457080877-13456-1-git-send-email-xavier.huwei@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1457080877-13456-1-git-send-email-xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This submit add binding file and dts file.

Signed-off-by: Wei Hu(Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 .../bindings/infiniband/hisilicon-hns-roce.txt     | 68 ++++++++++++++++++++++
 1 file changed, 68 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt

diff --git a/Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt b/Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt
new file mode 100644
index 0000000..8004641
--- /dev/null
+++ b/Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt
@@ -0,0 +1,68 @@
+HiSilicon RoCE DT description
+
+HiSilicon RoCE engine is a part of network subsystem.
+It works depending on other part of network wubsytem, such as, gmac and
+dsa fabric.
+
+Additional properties are described here:
+
+Required properties:
+- compatible: Should contain "hisilicon,hns-roce-v1".
+- reg: Physical base address of the roce driver and
+length of memory mapped region.
+- eth-handle: phandle, specifies a reference to a node
+representing a ethernet device.
+- dsaf-handle: phandle, specifies a reference to a node
+representing a dsaf device.
+- #address-cells: must be 2
+- #size-cells: must be 2
+Optional properties:
+- dma-coherent: Present if DMA operations are coherent.
+- interrupt-parent: the interrupt parent of this device.
+- interrupts: should contain 32 completion event irq,1 async event irq
+and 1 event overflow irq.
+Example:
+	rocee@0xc4000000 {
+			compatible = "hisilicon,hns-roce-v1";
+			reg = <0x0 0xc4000000 0x0 0x100000>;
+			dma-coherent;
+			eth-handle = <&eth2 &eth3 &eth4 &eth5 &eth6 &eth7>;
+			dsaf-handle = <&soc0_dsa>;
+			#address-cells = <2>;
+			#size-cells = <2>;
+			interrupt-parent = <&mbigen_dsa>;
+			interrupts = <722 1>,
+					<723 1>,
+					<724 1>,
+					<725 1>,
+					<726 1>,
+					<727 1>,
+					<728 1>,
+					<729 1>,
+					<730 1>,
+					<731 1>,
+					<732 1>,
+					<733 1>,
+					<734 1>,
+					<735 1>,
+					<736 1>,
+					<737 1>,
+					<738 1>,
+					<739 1>,
+					<740 1>,
+					<741 1>,
+					<742 1>,
+					<743 1>,
+					<744 1>,
+					<745 1>,
+					<746 1>,
+					<747 1>,
+					<748 1>,
+					<749 1>,
+					<750 1>,
+					<751 1>,
+					<752 1>,
+					<753 1>,
+					<785 1>,
+					<754 4>;
+		};
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
