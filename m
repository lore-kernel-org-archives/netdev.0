From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V4 net-next 7/8] net: hns3: Add Ethtool support to HNS3
 driver
Date: Thu, 27 Jul 2017 11:04:53 -0700
Message-ID: <0fa12c08-8d20-5bb2-5e56-c083c57922e2@gmail.com>
References: <20170722220942.78852-1-salil.mehta@huawei.com>
 <20170722220942.78852-8-salil.mehta@huawei.com>
 <23ddbe00-8bef-a09b-5783-3a5438086bd6@gmail.com>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B8283E1@FRAEML521-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        huangdaode <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
        "lipeng (Y)" <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linuxarm <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F93B8283E1-WFPaWmAhWqtUuCJht5byYAK1hpo4iccwjNknBlVQO8k@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/27/2017 11:01 AM, Salil Mehta wrote:
> Hi Florian,
> 
>> -----Original Message-----
>> From: Florian Fainelli [mailto:f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org]
>> Sent: Sunday, July 23, 2017 6:05 PM
>> To: Salil Mehta; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
>> Cc: Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
>> mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
>> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Linuxarm
>> Subject: Re: [PATCH V4 net-next 7/8] net: hns3: Add Ethtool support to
>> HNS3 driver
>>
>>
>>
>> On 07/22/2017 03:09 PM, Salil Mehta wrote:
>>> This patch adds the support of the Ethtool interface to
>>> the HNS3 Ethernet driver. Various commands to read the
>>> statistics, configure the offloading, loopback selftest etc.
>>> are supported.
>>>
>>> Signed-off-by: Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
>>> Signed-off-by: lipeng <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>> Signed-off-by: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>> Signed-off-by: Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>> ---
>>> Patch V4: addressed below comments
>>>  1. Andrew Lunn
>>>     Removed the support of loop PHY back for now
>>> Patch V3: Address below comments
>>>  1. Stephen Hemminger
>>>     https://lkml.org/lkml/2017/6/13/974
>>>  2. Andrew Lunn
>>>     https://lkml.org/lkml/2017/6/13/1037
>>> Patch V2: No change
>>> Patch V1: Initial Submit
>>> ---
>>>  .../ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c  | 543
>> +++++++++++++++++++++
>>>  1 file changed, 543 insertions(+)
>>>  create mode 100644
>> drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
>>>
>>> diff --git
>> a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
>> b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
>>> new file mode 100644
>>> index 000000000000..82b0d4d829f8
>>> --- /dev/null
>>> +++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
>>> @@ -0,0 +1,543 @@
>>> +/*
>>> + * Copyright (c) 2016~2017 Hisilicon Limited.
>>> + *
>>> + * This program is free software; you can redistribute it and/or
>> modify
>>> + * it under the terms of the GNU General Public License as published
>> by
>>> + * the Free Software Foundation; either version 2 of the License, or
>>> + * (at your option) any later version.
>>> + */
>>> +
>>> +#include <linux/etherdevice.h>
>>> +#include "hns3_enet.h"
>>> +
>>> +struct hns3_stats {
>>> +	char stats_string[ETH_GSTRING_LEN];
>>> +	int stats_size;
>>> +	int stats_offset;
>>> +};
>>> +
>>> +/* netdev related stats */
>>> +#define HNS3_NETDEV_STAT(_string, _member)			\
>>> +	{ _string,						\
>>> +	  FIELD_SIZEOF(struct rtnl_link_stats64, _member),	\
>>> +	  offsetof(struct rtnl_link_stats64, _member),		\
>>> +	}
>>
>> Can you make this macro use named initializers?
> Can you please explain bit more or point out some
> example. This would be very handy. 

	.stat_string = _string,
	.stats_size = FIELD_SIZEOF(struct rtnl_link_stat64, _member),
	.stats_offset = offsetof(struct rtnl_link_stats64, _member),

https://gcc.gnu.org/onlinedocs/gcc/Designated-Inits.html
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
