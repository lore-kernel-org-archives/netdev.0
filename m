From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH -next v2] net: hns: fix return value check in
 hns_dsaf_get_cfg()
Date: Mon, 5 Sep 2016 14:20:33 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A6FA0CA@lhreml503-mbx>
References: <1467644458-10131-1-git-send-email-weiyj_lk@163.com>
 <1467705412-30194-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "weiyj_lk@163.com" <weiyj_lk@163.com>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lhrrgout.huawei.com ([194.213.3.17]:3370 "EHLO
        lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934322AbcIEOVA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 10:21:00 -0400
In-Reply-To: <1467705412-30194-1-git-send-email-weiyj_lk@163.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
This patch will conflict with Doug Ledford's hns-roce's HNS driver.
This might lead to problems later during this merge window of 4.9.

Therefore, Please re-submit it later. The patch files it has are
Directly conflicting with RoCE patches:

[PATCH for-next 1/2] net: hns: Add support of ACPI to HNS driver RoCE Reset function 
drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h
drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h

we are in process of streamlining the internal process for the better
synchronization between HNS and RoCE/RDMA teams and would maintain
internal repo for such conflicting patches and which can be
git-pulled by David Miller and Doug Ledford.

Best regards
Salil
> -----Original Message-----
> From: weiyj_lk@163.com [mailto:weiyj_lk@163.com]
> Sent: Tuesday, July 05, 2016 8:57 AM
> To: Zhuangyuzeng (Yisen); Salil Mehta; Yankejian (Hackim Yim)
> Cc: Wei Yongjun; netdev@vger.kernel.org
> Subject: [PATCH -next v2] net: hns: fix return value check in
> hns_dsaf_get_cfg()
> 
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In case of error, function devm_ioremap_resource() returns ERR_PTR()
> and never returns NULL. The NULL test in the return value check should
> be replaced with IS_ERR().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 16 ++++++++------
> --
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> index 86ce28a..2ef4277 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> @@ -114,9 +114,9 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
> 
>  			dsaf_dev->sc_base = devm_ioremap_resource(&pdev->dev,
>  								  res);
> -			if (!dsaf_dev->sc_base) {
> +			if (IS_ERR(dsaf_dev->sc_base)) {
>  				dev_err(dsaf_dev->dev, "subctrl can not
> map!\n");
> -				return -ENOMEM;
> +				return PTR_ERR(dsaf_dev->sc_base);
>  			}
> 
>  			res = platform_get_resource(pdev, IORESOURCE_MEM,
> @@ -128,9 +128,9 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
> 
>  			dsaf_dev->sds_base = devm_ioremap_resource(&pdev-
> >dev,
>  								   res);
> -			if (!dsaf_dev->sds_base) {
> +			if (IS_ERR(dsaf_dev->sds_base)) {
>  				dev_err(dsaf_dev->dev, "serdes-ctrl can not
> map!\n");
> -				return -ENOMEM;
> +				return PTR_ERR(dsaf_dev->sds_base);
>  			}
>  		} else {
>  			dsaf_dev->sub_ctrl = syscon;
> @@ -146,9 +146,9 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
>  		}
>  	}
>  	dsaf_dev->ppe_base = devm_ioremap_resource(&pdev->dev, res);
> -	if (!dsaf_dev->ppe_base) {
> +	if (IS_ERR(dsaf_dev->ppe_base)) {
>  		dev_err(dsaf_dev->dev, "ppe-base resource can not map!\n");
> -		return -ENOMEM;
> +		return PTR_ERR(dsaf_dev->ppe_base);
>  	}
>  	dsaf_dev->ppe_paddr = res->start;
> 
> @@ -165,9 +165,9 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
>  			}
>  		}
>  		dsaf_dev->io_base = devm_ioremap_resource(&pdev->dev, res);
> -		if (!dsaf_dev->io_base) {
> +		if (IS_ERR(dsaf_dev->io_base)) {
>  			dev_err(dsaf_dev->dev, "dsaf-base resource can not
> map!\n");
> -			return -ENOMEM;
> +			return PTR_ERR(dsaf_dev->io_base);
>  		}
>  	}
> 
