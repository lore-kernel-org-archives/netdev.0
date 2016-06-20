From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: hns: add skb_reset_mac_header() after
 skb being alloc
Date: Mon, 20 Jun 2016 09:04:23 -0700 (PDT)
Message-ID: <20160620.090423.288030087667835728.davem@davemloft.net>
References: <20160614.224134.743787632695474309.davem@davemloft.net>
	<57612E38.6020301@huawei.com>
	<57679762.4060608@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: charles.chenxin@huawei.com, linuxarm@huawei.com,
	linux-kernel@vger.kernel.org, arnd@arndb.de, netdev@vger.kernel.org
To: Yisen.zhuang@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57679762.4060608@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Date: Mon, 20 Jun 2016 15:12:34 +0800

> 
> 
> 在 2016/6/15 18:30, Yisen Zhuang 写道:
>> Hi David,
>> 
>> Thanks for your suggestions.
>> 
>> Please see my comments below.
>> 
>> Thanks,
>> 
>> Yisen
>> 
>> 在 2016/6/15 13:41, David Miller 写道:
>>> From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
>>> Date: Mon, 13 Jun 2016 20:41:22 +0800
>>>
>>>> From: Kejian Yan <yankejian@huawei.com>
>>>>
>>>> HNS receives a packet without doing anything, but it should call
>>>> skb_reset_mac_header() to initialize the header before using
>>>> eth_hdr().
>>>>
>>>> Fixes: 0d6b425a3773c3445b0f51b2f333821beaacb619
>>>> Signed-off-by: Kejian Yan <yankejian@huawei.com>
>>>> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
>>>
>>> Well, this patch made me look at this function.
>>>
>>> You really shouldn't be filtering packets looped back, that is
>>> the stack's job.  It shouldn't be happening in the driver.
>> 
>> If we use ping6 to test if it is connected to network, CPUs would send out the NS packets
>> and these packets will be looped back to CPUs. If driver does not drop these packets,
>> they will be sent to protocol stack and protocol stack consider that there is a device
>> with the same address and it is not available address. It will show us the log like
>> "connect: Cannot assign requested address". Then it can not connect to the network enviroment.
>> Thus, we drop these packets looped back in HNS driver.
>> 
> 
> Hi David,
> 
> What is the opinion about this issue? We need this patch to resolve the issue.

I guess this is fine if your chip behaves this way.
