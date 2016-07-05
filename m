From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH -next] net: hns: fix return value check in
 hns_dsaf_get_cfg()
Date: Tue, 5 Jul 2016 15:08:45 +0300
Message-ID: <8152b0da-c43a-8657-fe23-98c9441bf79f@cogentembedded.com>
References: <1467644458-10131-1-git-send-email-weiyj_lk@163.com>
 <20160705.000856.969400031985428200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
	yankejian@huawei.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:34641 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754302AbcGEMIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 08:08:49 -0400
Received: by mail-lf0-f45.google.com with SMTP id h129so133388612lfh.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 05:08:48 -0700 (PDT)
In-Reply-To: <20160705.000856.969400031985428200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 7/5/2016 10:08 AM, David Miller wrote:

>>
>>  	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "ppe-base");
>> -	if (!res) {
>> +	if (!res)
>>  		res = platform_get_resource(pdev, IORESOURCE_MEM, res_idx++);
>> -		if (!res) {
>> -			dev_err(dsaf_dev->dev, "ppe-base info is needed!\n");
>> -			return -ENOMEM;
>> -		}
>> -	}
>
> platform_get_resource() can return NULL, you can't just remove this check.

    He can -- since devm_ioremap_resource() called right afterwards checks for 
NULL.

> This is also a case of a patch trying to do many things at once, and that's
> why bugs like this tend to slip in.

    Agreed.

MBR, Sergei
