From: yankejian <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 next 2/2] net: hns: fixes no syscon error when init mdio
Date: Mon, 7 Dec 2015 16:25:07 +0800
Message-ID: <1449476707-224320-3-git-send-email-yankejian@huawei.com>
References: <1449476707-224320-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<wangkefeng.wang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <haojian.zhuang-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<wangzhou1-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <bintian.wang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<long.wanglong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <leo.yan-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449476707-224320-1-git-send-email-yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

as dtsi files use the normal naming conventions using '-' instead of '_'
inside of property names, the driver needs to update the phandle name
strings of the of_parse_phandle func.

Signed-off-by: yankejian <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/hisilicon/hns_mdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns_mdio.c b/drivers/net/ethernet/hisilicon/hns_mdio.c
index 37491c8..1e07e91 100644
--- a/drivers/net/ethernet/hisilicon/hns_mdio.c
+++ b/drivers/net/ethernet/hisilicon/hns_mdio.c
@@ -458,7 +458,7 @@ static int hns_mdio_probe(struct platform_device *pdev)
 	}
 
 	mdio_dev->subctrl_vbase =
-		syscon_node_to_regmap(of_parse_phandle(np, "subctrl_vbase", 0));
+		syscon_node_to_regmap(of_parse_phandle(np, "subctrl-vbase", 0));
 	if (IS_ERR(mdio_dev->subctrl_vbase)) {
 		dev_warn(&pdev->dev, "no syscon hisilicon,peri-c-subctrl\n");
 		mdio_dev->subctrl_vbase = NULL;
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
