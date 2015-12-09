From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [PATCH net-next 1/2] net: hns: enet specisies a reference to dsaf
Date: Wed, 9 Dec 2015 18:39:59 +0800
Message-ID: <566804FF.5000607@huawei.com>
References: <1449302356-54658-1-git-send-email-yankejian@huawei.com>
 <1449302356-54658-2-git-send-email-yankejian@huawei.com>
 <56671D27.5070700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <devicetree@vger.kernel.org>, <haifeng.wei@huawei.com>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>, <davem@davemloft.net>,
	<arnd@arndb.de>, <fengguang.wu@intel.com>, <robh+dt@kernel.org>,
	<pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<salil.mehta@huawei.com>, <Yisen.Zhuang@huawei.com>,
	<liguozhu@huawei.com>, <lisheng011@huawei.com>,
	<huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56671D27.5070700@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/12/9 2:10, Florian Fainelli wrote:
> Subject: s/specisies/specifies/?

Thanks for pointing it out. i will change it in next patchset.

Best Regards,
yankejian

> On 04/12/15 23:59, yankejian wrote:
>> enet is associating with dasf. before this patch, the association is
>> the same strings between ae-name and dsa-name. in a general way, enet
>> specifies a reference to dsaf should be a good idea. so this patch
>> deletes the ae-name in enet, and adds parsing the ae-handle
>> from DT to set the associating with dsaf.
>>
>> Signed-off-by: yankejian <yankejian@huawei.com>
>> ---
> [snip]
>
>> diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
>> index b364529..3bfe36f 100644
>> --- a/drivers/net/ethernet/hisilicon/hns/hnae.c
>> +++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
>> @@ -95,21 +95,17 @@ static struct hnae_buf_ops hnae_bops = {
>>  static int __ae_match(struct device *dev, const void *data)
>>  {
>>  	struct hnae_ae_dev *hdev = cls_to_ae_dev(dev);
>> -	const char *ae_id = data;
>>  
>> -	if (!strncmp(ae_id, hdev->name, AE_NAME_SIZE))
>> -		return 1;
>> -
>> -	return 0;
>> +	return hdev->dev->of_node == data;
>>  }
>>  
>> -static struct hnae_ae_dev *find_ae(const char *ae_id)
>> +static struct hnae_ae_dev *find_ae(const struct device_node *ae_node)
>>  {
>>  	struct device *dev;
>>  
>> -	WARN_ON(!ae_id);
>> +	WARN_ON(!ae_node);
>>  
>> -	dev = class_find_device(hnae_class, NULL, ae_id, __ae_match);
>> +	dev = class_find_device(hnae_class, NULL, ae_node, __ae_match);
> of_find_net_device_by_node might be used for this maybe?
it needs return hnae_ae_dev so we didn't decide to use of_find_net_device_by_node.
Thanks
