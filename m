From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v11 03/22] IB/hns: Add initial main frame driver and get cfg info
Date: Sat, 2 Jul 2016 17:39:05 +0800
Message-ID: <1467452364-66522-4-git-send-email-oulijun@huawei.com>
References: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467452364-66522-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch mainly added the initial bare main driver. It
could get the relative configure information of net node.

Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
PATCH v11:
This fixes comments given by Leon Romanovsky over the PATCH v10:
  Link: https://lkml.org/lkml/2016/6/24/276

PATCH v10:
This fixes comments given by Leon Romanovsky over the PATCH v9:
  Link: https://lkml.org/lkml/2016/6/9/56

PATCH v9/v8/v7/v6:
- No change over the PATCH v5

PATCH v5:
- The initial patch which was redesigned based on the second patch
  in PATCH v4
---
---
 drivers/infiniband/hw/hns/hns_roce_device.h |  66 ++++++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   | 179 ++++++++++++++++++++++++++++
 2 files changed, 245 insertions(+)
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_device.h
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_main.c

diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
new file mode 100644
index 0000000..4775028
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -0,0 +1,66 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef _HNS_ROCE_DEVICE_H
+#define _HNS_ROCE_DEVICE_H
+
+#include <rdma/ib_verbs.h>
+
+#define DRV_NAME "hns_roce"
+
+#define HNS_ROCE_MAX_IRQ_NUM			34
+#define HNS_ROCE_MAX_PORTS			6
+
+struct hns_roce_ib_iboe {
+	struct net_device      *netdevs[HNS_ROCE_MAX_PORTS];
+	u8			phy_port[HNS_ROCE_MAX_PORTS];
+};
+
+struct hns_roce_caps {
+	u8		num_ports;
+};
+
+struct hns_roce_dev {
+	struct ib_device	ib_dev;
+	struct platform_device  *pdev;
+	const char		*irq_names;
+	struct hns_roce_ib_iboe iboe;
+
+	int			irq[HNS_ROCE_MAX_IRQ_NUM];
+	u8 __iomem		*reg_base;
+	struct hns_roce_caps	caps;
+
+	int			cmd_mod;
+	int			loop_idc;
+};
+
+#endif /* _HNS_ROCE_DEVICE_H */
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
new file mode 100644
index 0000000..07dd838
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -0,0 +1,179 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ * Copyright (c) 2007, 2008 Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/of_platform.h>
+#include <rdma/ib_addr.h>
+#include <rdma/ib_smi.h>
+#include <rdma/ib_user_verbs.h>
+#include "hns_roce_device.h"
+
+static int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
+{
+	int i;
+	u8 phy_port;
+	int port_cnt = 0;
+	struct device *dev = &hr_dev->pdev->dev;
+	struct device_node *np = dev->of_node;
+	struct device_node *net_node;
+	struct net_device *netdev = NULL;
+	struct platform_device *pdev = NULL;
+	struct resource *res;
+
+	if (!of_device_is_compatible(np, "hisilicon,hns-roce-v1")) {
+		dev_err(dev, "device no compatible!\n");
+		return -EINVAL;
+	}
+
+	res = platform_get_resource(hr_dev->pdev, IORESOURCE_MEM, 0);
+	hr_dev->reg_base = devm_ioremap_resource(dev, res);
+	if (!hr_dev->reg_base)
+		return -ENOMEM;
+
+	for (i = 0; i < HNS_ROCE_MAX_PORTS; i++) {
+		net_node = of_parse_phandle(np, "eth-handle", i);
+		if (net_node) {
+			pdev = of_find_device_by_node(net_node);
+			netdev = platform_get_drvdata(pdev);
+			phy_port = (u8)i;
+			if (netdev) {
+				hr_dev->iboe.netdevs[port_cnt] = netdev;
+				hr_dev->iboe.phy_port[port_cnt] = phy_port;
+			} else {
+				return -ENODEV;
+			}
+			port_cnt++;
+		}
+	}
+
+	if (port_cnt == 0) {
+		dev_err(dev, "Unable to get available port by eth-handle!\n");
+		return -EINVAL;
+	}
+
+	hr_dev->caps.num_ports = port_cnt;
+
+	/* Cmd issue mode: 0 is poll, 1 is event */
+	hr_dev->cmd_mod = 1;
+	hr_dev->loop_idc = 0;
+
+	for (i = 0; i < HNS_ROCE_MAX_IRQ_NUM; i++) {
+		hr_dev->irq[i] = platform_get_irq(hr_dev->pdev, i);
+		if (hr_dev->irq[i] <= 0) {
+			dev_err(dev, "Get No.%d irq resource failed!\n", i);
+			return -EINVAL;
+		}
+
+		if (of_property_read_string_index(np, "interrupt-names", i,
+						  &hr_dev->irq_names))
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
+/**
+* hns_roce_probe - RoCE driver entrance
+* @pdev: pointer to platform device
+* Return : int
+*
+*/
+static int hns_roce_probe(struct platform_device *pdev)
+{
+	int ret;
+	struct hns_roce_dev *hr_dev;
+	struct device *dev = &pdev->dev;
+
+	hr_dev = (struct hns_roce_dev *)ib_alloc_device(sizeof(*hr_dev));
+	if (!hr_dev)
+		return -ENOMEM;
+
+	memset((u8 *)hr_dev + sizeof(struct ib_device), 0,
+		sizeof(struct hns_roce_dev) - sizeof(struct ib_device));
+
+	hr_dev->pdev = pdev;
+	platform_set_drvdata(pdev, hr_dev);
+
+	if (dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64ULL)) &&
+	    dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32ULL))) {
+		dev_err(dev, "No usable DMA addressing mode\n");
+		ret = -EIO;
+		goto error_failed_get_cfg;
+	}
+
+	ret = hns_roce_get_cfg(hr_dev);
+	if (ret) {
+		dev_err(dev, "Get Configuration failed!\n");
+		goto error_failed_get_cfg;
+	}
+
+error_failed_get_cfg:
+	ib_dealloc_device(&hr_dev->ib_dev);
+
+	return ret;
+}
+
+/**
+* hns_roce_remove - remove roce device
+* @pdev: pointer to platform device
+*/
+static int hns_roce_remove(struct platform_device *pdev)
+{
+	struct hns_roce_dev *hr_dev = platform_get_drvdata(pdev);
+
+	ib_dealloc_device(&hr_dev->ib_dev);
+
+	return 0;
+}
+
+static const struct of_device_id hns_roce_of_match[] = {
+	{ .compatible = "hisilicon,hns-roce-v1",},
+	{},
+};
+MODULE_DEVICE_TABLE(of, hns_roce_of_match);
+
+static struct platform_driver hns_roce_driver = {
+	.probe = hns_roce_probe,
+	.remove = hns_roce_remove,
+	.driver = {
+		.name = DRV_NAME,
+		.of_match_table = hns_roce_of_match,
+	},
+};
+
+module_platform_driver(hns_roce_driver);
+
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_AUTHOR("Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>");
+MODULE_AUTHOR("Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>");
+MODULE_AUTHOR("Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>");
+MODULE_DESCRIPTION("HISILICON RoCE driver");
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
