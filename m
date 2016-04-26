From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v5 09/21] IB/hns: Add hca support
Date: Tue, 26 Apr 2016 16:25:17 +0200
Message-ID: <20160426142517.GA1937@nanopsycho.orion>
References: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
 <1461407219-72027-10-git-send-email-oulijun@huawei.com>
 <20160424075424.GE7974@leon.nu>
 <571F0C04.2010005@huawei.com>
 <20160426141821.GJ7974@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oulijun <oulijun@huawei.com>, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jiri@mellanox.com, ogerlitz@mellanox.com, linuxarm@huawei.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gongyangming@huawei.com,
	xiaokun@huawei.com, tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	lisheng011@huawei.com, charles.chenxin@huawei.com
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34909 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbcDZOZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 10:25:20 -0400
Received: by mail-wm0-f65.google.com with SMTP id e201so4870705wme.2
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 07:25:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160426141821.GJ7974@leon.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Apr 26, 2016 at 04:18:21PM CEST, leon@kernel.org wrote:
>On Tue, Apr 26, 2016 at 02:34:44PM +0800, oulijun wrote:
>> On 2016/4/24 15:54, Leon Romanovsky wrote:

<snip>

>> >> +int hns_roce_bitmap_alloc(struct hns_roce_bitmap *bitmap, u32 *obj)
>> >> +{
>> >> +	int ret = 0;
>> >> +
>> >> +	spin_lock(&bitmap->lock);
>> >> +	*obj = find_next_zero_bit(bitmap->table, bitmap->max, bitmap->last);
>> >> +	if (*obj >= bitmap->max) {
>> >> +		bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
>> >> +			       & bitmap->mask;
>> >> +		*obj = find_first_zero_bit(bitmap->table, bitmap->max);
>> > 
>> > find_first_zero_bit function returns "unsigned long" which may or may
>> > not be equal to u32 on some architectures.
>> > 
>> Hi Leon,
>>     I appreciate your keen eye. this code is meant for ARM64bit therefore should run corretly for 64-bit AARCH64.

The driver should run correctly on any arch.


>> I will consider changing it as part of good partice and better portability "
>> I will give a primary plan to modified it.
>> for example:
>>     *obj = (u32)find_next_zero_bit(bitmap->table, bitmap->max, bitmap->last);
>> Beause the max size of bitmap->table is u32 in current version.
>> 
>> int hns_roce_bitmap_init(struct hns_roce_bitmap *bitmap, u32 num, u32 mask,
>> 			 u32 reserved_bot, u32 reserved_top)
>> {
>> 	u32 i;
>> 
>> 	if (num != roundup_pow_of_two(num))
>> 		return -EINVAL;
>> 
>> 	bitmap->last = 0;
>> 	bitmap->top = 0;
>> 	bitmap->max = num - reserved_top;
>> 	bitmap->mask = mask;
>> 	bitmap->reserved_top = reserved_top;
>> 	spin_lock_init(&bitmap->lock);
>> 	bitmap->table = kcalloc(BITS_TO_LONGS(bitmap->max), sizeof(long),
>> 				GFP_KERNEL);
>> 
>> Is this plan ok?
>
>No,
>You are submitting new driver, please do it properly (without casting)
>from the beginning.
>
>> 
>> Thanks
>> Lijun Ou
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
