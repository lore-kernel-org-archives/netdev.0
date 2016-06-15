From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [patch net-next] net: hns: add skb_reset_mac_header() after skb
 being alloc
Date: Wed, 15 Jun 2016 18:30:16 +0800
Message-ID: <57612E38.6020301@huawei.com>
References: <1465821682-223053-1-git-send-email-Yisen.Zhuang@huawei.com>
 <20160614.224134.743787632695474309.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <arnd@arndb.de>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxarm@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614.224134.743787632695474309.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Thanks for your suggestions.

Please see my comments below.

Thanks,

Yisen

=E5=9C=A8 2016/6/15 13:41, David Miller =E5=86=99=E9=81=93:
> From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
> Date: Mon, 13 Jun 2016 20:41:22 +0800
>=20
>> From: Kejian Yan <yankejian@huawei.com>
>>
>> HNS receives a packet without doing anything, but it should call
>> skb_reset_mac_header() to initialize the header before using
>> eth_hdr().
>>
>> Fixes: 0d6b425a3773c3445b0f51b2f333821beaacb619
>> Signed-off-by: Kejian Yan <yankejian@huawei.com>
>> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
>=20
> Well, this patch made me look at this function.
>=20
> You really shouldn't be filtering packets looped back, that is
> the stack's job.  It shouldn't be happening in the driver.

If we use ping6 to test if it is connected to network, CPUs would send =
out the NS packets
and these packets will be looped back to CPUs. If driver does not drop =
these packets,
they will be sent to protocol stack and protocol stack consider that th=
ere is a device
with the same address and it is not available address. It will show us =
the log like
"connect: Cannot assign requested address". Then it can not connect to =
the network enviroment.
Thus, we drop these packets looped back in HNS driver.

>=20
> And once you remove that code, this patch here is no longer
> necessary.
>=20
> Second of all, unless you card supports every protocol that
> exists in the past, present, and _future_ you cannot set
> skb->ip_summed to CHECKSUM_UNNECSSARY unconditionally like
> that.
>=20
> You can only set that for protocols your chip actually supports.

Thanks for your suggestions. I will prepare a new patch to fix it.

>=20
> .
>=20
