From: Salil Mehta <salil.mehta@huawei.com>
Subject: Re: [PATCH V6 net-next 5/5] net:hns: Add the init code to disable
 Hip06 "Hardware VLAN assist"
Date: Fri, 4 Dec 2015 18:18:38 +0000
Message-ID: <5661D8FE.2010909@huawei.com>
References: <1449075171-4820-1-git-send-email-salil.mehta@huawei.com> <1449075171-4820-6-git-send-email-salil.mehta@huawei.com> <565F4AB0.5020100@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <paul.gortmaker@windriver.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>, <arnd@arndb.de>,
	<liguozhu@hisilicon.com>, <yisen.zhuang@huawei.com>,
	<dingtianhong@huawei.com>, <zhangfei.gao@linaro.org>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<mehta.salil.lnk@gmail.com>, <xuwei5@hisilicon.com>,
	<lisheng011@huawei.com>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:37845 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977AbbLDS0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 13:26:13 -0500
In-Reply-To: <565F4AB0.5020100@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/2/2015 7:46 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 12/02/2015 07:52 PM, Salil Mehta wrote:
>
>> This patch adds the initializzation code to disable the hardware
>> vlan support for VLAN Tag stripping by default for now.
>>
>> Proper support of "hardware VLAN assitance" feature would
>> soon come in the next coming patches.
>>
>> Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
>> ---
>>
>> PATCH V6:
>> - No change over the earlier patch
>>
>> PATCH V5:
>> - Minor merge/reject change resolved to application of previous patch
>>
>> PATCH V4/V3/V2:
>> - No change over the initial floated patch
>>
>> PATCH V1:
>> - Initial code to disable the hardware VLAN assist for now
>> ---
>>   drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c |    7 +++++++
>>   drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h |    1 +
>>   2 files changed, 8 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c 
>> b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
>> index b5e4c44..f302ef9 100644
>> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
>> @@ -176,6 +176,11 @@ static void hns_ppe_cnt_clr_ce(struct hns_ppe_cb 
>> *ppe_cb)
>>                PPE_CNT_CLR_CE_B, 1);
>>   }
>>
>> +static void hns_ppe_set_vlan_strip(struct hns_ppe_cb *ppe_cb, int en)
>> +{
>> +    dsaf_write_dev(ppe_cb, PPEV2_VLAN_STRIP_EN_REG, en);
>
>    Why not call it directly?
Hi Sergei,
The wrapper API abstraction has been put intentionally. The reason is 
the same code
is suppose to run across different SoCs so it is always clean approach 
to hide it so
that even if there are differences in the way we access or configure 
hardware
in other SoCs basic interface of the SET API remains same!!
Therefore, we are in favour of keeping the above wrapper and therefore not
changing now.

Best regards
Salil
>> +}
>> +
>>   /**
>>    * hns_ppe_checksum_hw - set ppe checksum caculate
>>    * @ppe_device: ppe device
>> @@ -336,6 +341,8 @@ static void hns_ppe_init_hw(struct hns_ppe_cb 
>> *ppe_cb)
>>       hns_ppe_cnt_clr_ce(ppe_cb);
>>
>>       if (!AE_IS_VER1(dsaf_dev->dsaf_ver)) {
>> +        hns_ppe_set_vlan_strip(ppe_cb, 0);
>> +
>>           /* set default RSS key in h/w */
>>           hns_ppe_set_rss_key(ppe_cb, ppe_cb->rss_key);
>>
>> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h 
>> b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
>> index 98c163e..6c18ca9 100644
>> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
>> @@ -318,6 +318,7 @@
>>   #define PPE_CFG_PARSE_TAG_REG            0x94
>>   #define PPE_CFG_PRO_CHECK_EN_REG        0x98
>>   #define PPEV2_CFG_TSO_EN_REG                    0xA0
>> +#define PPEV2_VLAN_STRIP_EN_REG                 0xAC
>
>    Please indent with tabs, like all the surrounding #define's are 
> indented (except PPEV2_CFG_TSO_EN_REG).
Thanks for this. I have changed this in PATCH V7 already floated.

Best Regards
Salil
>>   #define PPE_INTEN_REG 0x100
>>   #define PPE_RINT_REG                0x104
>>   #define PPE_INTSTS_REG                0x108
>
> MBR, Sergei
>
