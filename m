From: Lisheng011 <lisheng011@huawei.com>
Subject: Re: [PATCH net 4/4] net: hns: remove useless head=ring->next_to_clean
Date: Tue, 8 Mar 2016 16:02:04 +0800
Message-ID: <56DE86FC.8000408@huawei.com>
References: <1457409147-77086-1-git-send-email-lisheng011@huawei.com>
 <1457409147-77086-5-git-send-email-lisheng011@huawei.com>
 <1457421488.1347.5.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<xieqianqian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <netdev@vger.kernel.org>,
	<haifeng.wei@huawei.com>, <charles.chenxin@huawei.com>,
	<linuxarm@huawei.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:15366 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932179AbcCHIC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 03:02:29 -0500
In-Reply-To: <1457421488.1347.5.camel@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=E5=9C=A8 2016/3/8 15:18, Andy Shevchenko =E5=86=99=E9=81=93:
> On Tue, 2016-03-08 at 11:52 +0800, Lisheng wrote:
>> From: Qianqian Xie <xieqianqian@huawei.com>
>>
>> The variable head in hns_nic_tx_fini_pro has read a value,
>> but the value is not used. The patch will solve it.
>>
>> Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
>> ---
>>   drivers/net/ethernet/hisilicon/hns/hns_enet.c | 4 +---
>>   1 file changed, 1 insertion(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
>> b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
>> index 3f77ff7..7b4ec2f 100644
>> --- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
>> @@ -901,10 +901,8 @@ static int hns_nic_tx_poll_one(struct
>> hns_nic_ring_data *ring_data,
>>   static void hns_nic_tx_fini_pro(struct hns_nic_ring_data *ring_dat=
a)
>>   {
>>   	struct hnae_ring *ring =3D ring_data->ring;
>> -	int head =3D ring->next_to_clean;
>>  =20
> This empty line is a leftover, I prefer to just cut assignment.

Yeah,  the empty line does not be needed. I'll remove it. thx.



>> -	/* for hardware bug fixed */
> This is not good. Explanation is needed why you removed this comment.

This bug-fixed comment is for the function pointer=20
ring_data->fini_process,that is called in function hns_nic_common_poll.
The comment should not be here, so remove it.


>> -	head =3D readl_relaxed(ring->io_base + RCB_REG_HEAD);
>> +	int head =3D readl_relaxed(ring->io_base + RCB_REG_HEAD);
>>  =20
>>   	if (head !=3D ring->next_to_clean) {
>>   		ring_data->ring->q->handle->dev->ops-
>>> toggle_ring_irq(
