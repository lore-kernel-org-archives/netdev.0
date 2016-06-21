From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Subject: Re: [PATCH v10 06/22] IB/hns: Add initial cmd operation
Date: Tue, 21 Jun 2016 18:50:51 +0800
Message-ID: <57691C0B.8090509@huawei.com>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-7-git-send-email-oulijun@huawei.com>
 <20160620133310.GB4526@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>, <linux-rdma@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<gongyangming@huawei.com>, <xiaokun@huawei.com>,
	<tangchaofei@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <leon@kernel.org>, Lijun Ou <oulijun@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:8801 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbcFUKwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 06:52:13 -0400
In-Reply-To: <20160620133310.GB4526@leon.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/6/20 21:33, Leon Romanovsky wrote:
> On Thu, Jun 16, 2016 at 10:35:14PM +0800, Lijun Ou wrote:
>> This patch added the operation for cmd, and added some functions
>> for initializing eq table and selecting cmd mode.
>>
>> Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
>> Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
>> Signed-off-by: Lijun Ou <oulijun@huawei.com>
>> ---
>> PATCH v9/v8/v7/v6:
>> - No change over the PATCH v5
>>
>> PATCH v5:
>> - The initial patch which was redesigned based on the second patch
>>    in PATCH v4
>> ---
> <...>
>
>> +#define CMD_MAX_NUM		32
>> +
>> +int hns_roce_cmd_init(struct hns_roce_dev *hr_dev)
>> +{
>> +	struct device *dev = &hr_dev->pdev->dev;
>> +
>> +	mutex_init(&hr_dev->cmd.hcr_mutex);
>> +	sema_init(&hr_dev->cmd.poll_sem, 1);
>> +	hr_dev->cmd.use_events = 0;
>> +	hr_dev->cmd.toggle = 1;
>> +	hr_dev->cmd.max_cmds = CMD_MAX_NUM;
> <...>
>
>> +	for (hr_cmd->token_mask = 1; hr_cmd->token_mask < hr_cmd->max_cmds;
>> +	     hr_cmd->token_mask <<= 1)
>> +		;
>> +	--hr_cmd->token_mask;
> It doesn't look that you dynamically change max_cmds supported.
> Why do you need to calculate token_mask dynamically?
Hi, Leon

     1. The four lines above are in the function named 
hns_roce_cmd_use_events.
          and now this function is only called once in hns_roce_probe.
     2. In hns_roce_cmd_use_events,
         we use these 4 lines to achieve the value of hr_cmd->token_mask 
according to hr_cmd->max_cmds dynamically,
         then we only define one marco for hr_cmd->max_cmds as below:

	#define CMD_MAX_NUM		32

        And it looks more flexible.

Regards
Wei Hu
