From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: hns: fix return value check in
 hns_dsaf_get_cfg()
Date: Tue, 05 Jul 2016 00:08:56 -0700 (PDT)
Message-ID: <20160705.000856.969400031985428200.davem@davemloft.net>
References: <1467644458-10131-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
	yankejian@huawei.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221AbcGEHI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 03:08:57 -0400
In-Reply-To: <1467644458-10131-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Mon,  4 Jul 2016 15:00:58 +0000

>  
>  	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "ppe-base");
> -	if (!res) {
> +	if (!res)
>  		res = platform_get_resource(pdev, IORESOURCE_MEM, res_idx++);
> -		if (!res) {
> -			dev_err(dsaf_dev->dev, "ppe-base info is needed!\n");
> -			return -ENOMEM;
> -		}
> -	}

platform_get_resource() can return NULL, you can't just remove this check.

This is also a case of a patch trying to do many things at once, and that's
why bugs like this tend to slip in.
