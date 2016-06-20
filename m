From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [patch net-next] net: hns: add skb_reset_mac_header() after skb
 being alloc
Date: Mon, 20 Jun 2016 15:12:34 +0800
Message-ID: <57679762.4060608@huawei.com>
References: <1465821682-223053-1-git-send-email-Yisen.Zhuang@huawei.com>
 <20160614.224134.743787632695474309.davem@davemloft.net>
 <57612E38.6020301@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <charles.chenxin@huawei.com>, <linuxarm@huawei.com>,
	<linux-kernel@vger.kernel.org>, <arnd@arndb.de>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:24294 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737AbcFTHNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 03:13:06 -0400
In-Reply-To: <57612E38.6020301@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=E5=9C=A8 2016/6/15 18:30, Yisen Zhuang =E5=86=99=E9=81=93:
> Hi David,
>=20
> Thanks for your suggestions.
>=20
> Please see my comments below.
>=20
> Thanks,
>=20
> Yisen
>=20
> =E5=9C=A8 2016/6/15 13:41, David Miller =E5=86=99=E9=81=93:
>> From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
>> Date: Mon, 13 Jun 2016 20:41:22 +0800
>>
>>> From: Kejian Yan <yankejian@huawei.com>
>>>
>>> HNS receives a packet without doing anything, but it should call
>>> skb_reset_mac_header() to initialize the header before using
>>> eth_hdr().
>>>
>>> Fixes: 0d6b425a3773c3445b0f51b2f333821beaacb619
>>> Signed-off-by: Kejian Yan <yankejian@huawei.com>
>>> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
>>
>> Well, this patch made me look at this function.
>>
>> You really shouldn't be filtering packets looped back, that is
>> the stack's job.  It shouldn't be happening in the driver.
>=20
> If we use ping6 to test if it is connected to network, CPUs would sen=
d out the NS packets
> and these packets will be looped back to CPUs. If driver does not dro=
p these packets,
> they will be sent to protocol stack and protocol stack consider that =
there is a device
> with the same address and it is not available address. It will show u=
s the log like
> "connect: Cannot assign requested address". Then it can not connect t=
o the network enviroment.
> Thus, we drop these packets looped back in HNS driver.
>=20

Hi David,

What is the opinion about this issue? We need this patch to resolve the=
 issue.

Hoping for your suggestions.

Many thanks,

Yisen

>>
>> And once you remove that code, this patch here is no longer
>> necessary.
>>
>> Second of all, unless you card supports every protocol that
>> exists in the past, present, and _future_ you cannot set
>> skb->ip_summed to CHECKSUM_UNNECSSARY unconditionally like
>> that.
>>
>> You can only set that for protocols your chip actually supports.
>=20
> Thanks for your suggestions. I will prepare a new patch to fix it.
>=20
>>
>> .
>>
>=20
> _______________________________________________
> linuxarm mailing list
> linuxarm@huawei.com
> http://rnd-openeuler.huawei.com/mailman/listinfo/linuxarm
>=20
