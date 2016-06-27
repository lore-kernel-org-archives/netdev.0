From: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v10 03/22] IB/hns: Add initial main frame driver and get
 cfg info
Date: Mon, 27 Jun 2016 15:29:32 +0800
Message-ID: <5770D5DC.1080200@huawei.com>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-4-git-send-email-oulijun@huawei.com>
 <20160624114831.GD23995@leon.nu> <576E5D0B.7010003@huawei.com>
 <20160627070054.GK23995@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	<sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160627070054.GK23995-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 2016/6/27 15:00, Leon Romanovsky wrote:
> On Sat, Jun 25, 2016 at 06:29:31PM +0800, Wei Hu (Xavier) wrote:
>>
>> On 2016/6/24 19:48, Leon Romanovsky wrote:
>>> On Thu, Jun 16, 2016 at 10:35:11PM +0800, Lijun Ou wrote:
>>>> This patch mainly added the initial bare main driver. It
>>>> could get the relative configure information of net node.
>>>>
>>>> Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>>> Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
>>>> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>>> ---
> ...
>
>>>> +		return -ENOMEM;
>>>> +
>>>> +	for (i = 0; i < HNS_ROCE_MAX_PORTS; i++) {
>>>> +		net_node = of_parse_phandle(np, "eth-handle", i);
>>>> +		if (net_node) {
>>>> +			pdev = of_find_device_by_node(net_node);
>>>> +			netdev = platform_get_drvdata(pdev);
>>>> +			phy_port = (u8)i;
>>>> +			if (netdev) {
>>>> +				hr_dev->iboe.netdevs[port_cnt] = netdev;
>>>> +				hr_dev->iboe.phy_port[port_cnt] = phy_port;
>>>> +			} else {
>>>> +				return -ENODEV;
>>>> +			}
>>>> +			port_cnt++;
>>>> +		}
>>>> +	}
>>> Do you want to check port_cnt value, before continue?
>> Hi, Leon
>>      Maybe we need not to check port_cnt value.
>>      port_cnt can be ensured smaller than HNS_ROCE_MAX_PORTS.
> You can in theory to get port_cnt == 0, in such case it is wise to
> return error.
I see.

Thanks
Wei Hu


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
