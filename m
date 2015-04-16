From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 2/6] net: hip04: use the big endian for tx and
 rx desc
Date: Thu, 16 Apr 2015 14:25:26 +0800
Message-ID: <552F55D6.1040307@huawei.com>
References: <1429101008-9464-1-git-send-email-dingtianhong@huawei.com> <1429101008-9464-3-git-send-email-dingtianhong@huawei.com> <6631765.x1c1LvG6uN@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <grant.likely@linaro.org>,
	<sergei.shtylyov@cogentembedded.com>,
	<linux-arm-kernel@lists.infradead.org>, <eric.dumazet@gmail.com>,
	<zhangfei.gao@linaro.org>, <joe@perches.com>,
	<netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux@arm.linux.org.uk>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:22199 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbbDPGaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 02:30:03 -0400
In-Reply-To: <6631765.x1c1LvG6uN@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/4/15 22:13, Arnd Bergmann wrote:
> On Wednesday 15 April 2015 20:30:04 Ding Tianhong wrote:
>> The hip04 ethernet use the big endian for tx and rx, so set desc to
>> big endian and remove the unused next_addr.
> 
> I don't understand:
> 
>> diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
>> index b0a7f03..6473462 100644
>> --- a/drivers/net/ethernet/hisilicon/hip04_eth.c
>> +++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
>> @@ -132,19 +132,18 @@
>>  #define HIP04_MIN_TX_COALESCE_FRAMES   1
>>  
>>  struct tx_desc {
>> -       u32 send_addr;
>> -       u32 send_size;
>> -       u32 next_addr;
>> -       u32 cfg;
>> -       u32 wb_addr;
>> +       __be32 send_addr;
>> +       __be32 send_size;
>> +       __be32 cfg;
>> +       __be32 wb_addr;
>>  } __aligned(64);
> 
> I would think this is a hardware structure, does this not break
> access to the cfg and wb_addr fields if you remove next_addr?
> 
> 	Arnd
> 
good cache, I make a mistake here, thanks.

> .
> 
