From: oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5 09/21] IB/hns: Add hca support
Date: Wed, 27 Apr 2016 11:34:31 +0800
Message-ID: <57203347.4000107@huawei.com>
References: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
 <1461407219-72027-10-git-send-email-oulijun@huawei.com>
 <20160424075424.GE7974@leon.nu> <571F0C04.2010005@huawei.com>
 <20160426141821.GJ7974@leon.nu> <20160426142517.GA1937@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160426142517.GA1937-6KJVSR23iU488b5SBfVpbw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2016/4/26 22:25, Jiri Pirko wrote:
> Tue, Apr 26, 2016 at 04:18:21PM CEST, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org wrote:
>> On Tue, Apr 26, 2016 at 02:34:44PM +0800, oulijun wrote:
>>> On 2016/4/24 15:54, Leon Romanovsky wrote:
> 
> <snip>
> 
>>>>> +int hns_roce_bitmap_alloc(struct hns_roce_bitmap *bitmap, u32 *obj)
>>>>> +{
>>>>> +	int ret = 0;
>>>>> +
>>>>> +	spin_lock(&bitmap->lock);
>>>>> +	*obj = find_next_zero_bit(bitmap->table, bitmap->max, bitmap->last);
>>>>> +	if (*obj >= bitmap->max) {
>>>>> +		bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
>>>>> +			       & bitmap->mask;
>>>>> +		*obj = find_first_zero_bit(bitmap->table, bitmap->max);
>>>>
>>>> find_first_zero_bit function returns "unsigned long" which may or may
>>>> not be equal to u32 on some architectures.
>>>>
>>> Hi Leon,
>>>     I appreciate your keen eye. this code is meant for ARM64bit therefore should run corretly for 64-bit AARCH64.
> 
> The driver should run correctly on any arch.
> 
 Hi Jiri Pirko,
    Our driver run in ARM64 platform by depending on Kconfig. It will be configure in Kconfig file.

Thanks
Lijun Ou
> 
>>> I will consider changing it as part of good partice and better portability "
>>> I will give a primary plan to modified it.
>>> for example:
>>>     *obj = (u32)find_next_zero_bit(bitmap->table, bitmap->max, bitmap->last);
>>> Beause the max size of bitmap->table is u32 in current version.
>>>
>>> int hns_roce_bitmap_init(struct hns_roce_bitmap *bitmap, u32 num, u32 mask,
>>> 			 u32 reserved_bot, u32 reserved_top)
>>> {
>>> 	u32 i;
>>>
>>> 	if (num != roundup_pow_of_two(num))
>>> 		return -EINVAL;
>>>
>>> 	bitmap->last = 0;
>>> 	bitmap->top = 0;
>>> 	bitmap->max = num - reserved_top;
>>> 	bitmap->mask = mask;
>>> 	bitmap->reserved_top = reserved_top;
>>> 	spin_lock_init(&bitmap->lock);
>>> 	bitmap->table = kcalloc(BITS_TO_LONGS(bitmap->max), sizeof(long),
>>> 				GFP_KERNEL);
>>>
>>> Is this plan ok?
>>
>> No,
>> You are submitting new driver, please do it properly (without casting)
>>from the beginning.
>>
>>>
>>> Thanks
>>> Lijun Ou
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 
> .
> 


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
