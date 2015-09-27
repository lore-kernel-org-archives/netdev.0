From: huangdaode <huangdaode@hisilicon.com>
Subject: Re: [PATCH net-next v3] net: Fix Hisilicon Network Subsystem Support
 Compilation
Date: Sun, 27 Sep 2015 15:19:09 +0800
Message-ID: <5607986D.7050700@hisilicon.com>
References: <1443169790-54861-1-git-send-email-huangdaode@hisilicon.com> <20150925.214256.1901015223799070196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<paul.gortmaker@windriver.com>, <dingtianhong@huawei.com>,
	<zhangfei.gao@linaro.org>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <salil.mehta@huawei.com>,
	<kenneth-lee-2012@foxmail.com>, <xuwei5@hisilicon.com>,
	<lisheng011@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:50958 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753354AbbI0HWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2015 03:22:36 -0400
In-Reply-To: <20150925.214256.1901015223799070196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/9/26 12:42, David Miller wrote:
> From: huangdaode <huangdaode@hisilicon.com>
> Date: Fri, 25 Sep 2015 16:29:50 +0800
>
>> @@ -191,9 +191,12 @@ static void hns_rcb_ring_init(struct ring_pair_cb *ring_pair, int ring_type)
>>   	if (ring_type == RX_RING) {
>>   		dsaf_write_dev(q, RCB_RING_RX_RING_BASEADDR_L_REG,
>>   			       (u32)dma);
>> +#ifdef CONFIG_64BIT
>>   		dsaf_write_dev(q, RCB_RING_RX_RING_BASEADDR_H_REG,
>>   			       (u32)(dma >> 32));
>> -
>> +#else
>> +		dsaf_write_dev(q, RCB_RING_RX_RING_BASEADDR_H_REG, 0);
>> +#endif
>>   		dsaf_write_dev(q, RCB_RING_RX_RING_BD_LEN_REG,
>>   			       bd_size_type);
>>   		dsaf_write_dev(q, RCB_RING_RX_RING_BD_NUM_REG,
> CONFIG_64BIT doesn't tell you if _DMA_ addresses are 64-bit or not.
>
> Furthermore there is a portable way to shift a 32-bit value down
> 32-bits whilst avoiding warnings.
>
> 	(x >> 31) >> 1
>
> So you should definitely use that instead of the CONFIG_64BIT test.
>
> .

agreed.
