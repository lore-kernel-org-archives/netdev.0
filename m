From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH 1/3] infiniband: IB/hns: add Hisilicon RoCE support
Date: Wed, 16 Mar 2016 11:36:38 +0100
Message-ID: <20160316103638.GB2254@nanopsycho.orion>
References: <1457692631-9290-1-git-send-email-oulijun@huawei.com>
 <1457692631-9290-2-git-send-email-oulijun@huawei.com>
 <20160311104239.GD3931@nanopsycho.orion>
 <56E9340E.3040207@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <56E9340E.3040207-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Wed, Mar 16, 2016 at 11:23:10AM CET, oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org wrote:
>Hi Jiri Pirko, thanks your reviewing.
>sorry, I will send a new patch according to your reviews.
>
>On 2016/3/11 18:42, Jiri Pirko wrote:
>> Fri, Mar 11, 2016 at 11:37:09AM CET, oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org wrote:
>>> The driver for Hisilicon RoCE is a platform driver.
>>> The driver will support mulitple versions of hardware. Currently only "v1"
>>> for hip06 SOC is supported.
>>> The driver includes two parts: common driver and hardware-specific
>>> operations. hns_roce_v1_hw.c and hns_roce_v1_hw.h are files for
>>> hardware-specific operations only for v1 engine, and other files(.c and .h)
>>> for common algorithm and common hardware operations
>>>
>>> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>> Signed-off-by: Wei Hu(Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>> Signed-off-by: Znlong <zhaonenglong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> 
>> <snip>
>> 
>> I'm sorry to be nitpicking, but you still have style issues in your
>> code. I believe that for newly submitted code, this should be avoided. I
>> already pointed that out as a comment to your last version, but you
>> ignored it. So again, couple of examples:
>> 
>>> +struct ib_ah *hns_roce_create_ah(struct ib_pd *ibpd,
>>> +					struct ib_ah_attr *ah_attr)
>> 
>> <snip>	
>> 	
>>> +	ret = ib_get_cached_gid(ibpd->device, ah_attr->port_num,
>>> +			ah_attr->grh.sgid_index, &sgid, &gid_attr);
>> 
>> <snip>
>> 
>>> +int hns_roce_bitmap_alloc_range(
>>> +					struct hns_roce_bitmap *bitmap,
>>> +					int cnt, int align, u32 *obj)
>> 
>> <snip>
>> 
>>> +			pages =
>>> +				kmalloc(sizeof(*pages) * buf->nbufs,
>>> +					GFP_KERNEL);
>> 
>In v2, I consider that it will violate checkpatch if write as follows
>	pages = kmalloc(sizeof(*pages) * buf->nbufs,
>			GFP_KERNEL);

Why it would be problem for checkpatch? I bet it won't.


>so, I continue to have it.

I will continue to bash on your odd codingstyle. Please fix it!



>Now, I have used kmalloc_array instead of it. I will send new patch at soon.
>Again, i am sorry for my incorrect plan.
>
>> <snip>
>> 
>>> +		dev_err(dev,
>>> +			"CQ alloc.Failed to find cq buf addr.\n");
>> 
>> <snip>
>> 
>>> +	resp.qp_tab_size      = hr_dev->caps.num_qps;
>> 
>> <snip>
>> 
>>> +		buddy->bits[i] =
>>> +			kmalloc(s * sizeof(long), GFP_KERNEL);
>> 
>> 
>> and many, many others similar to this. Please fix this.
>> 
>> 
>> Also, I don't understand why you have "_" prefix for labels:
>> 
>>> +
>>> +_error_failed_register_device:
>>> +	hns_roce_engine_uninit(hr_dev);
>>> +
>>> +_error_failed_engine_init:
>>> +	hns_roce_cleanup_bitmap(hr_dev);
>>> +
>>> +_error_failed_setup_hca:
>>> +	hns_roce_cleanup_icm(hr_dev);
>>> +
>>> +_error_failed_init_icm:
>>> +	if (hr_dev->cmd_mod)
>>> +		hns_roce_cmd_use_polling(hr_dev);
>>> +
>>> +_error_failed_use_event:
>>> +	hns_roce_cleanup_eq_table(hr_dev);
>>> +
>>> +_error_failed_eq_tabel:
>>> +	hns_roce_cmd_cleanup(hr_dev);
>>> +
>>> +_error_failed_cmd_init:
>>> +	(void)hns_roce_engine_reset(hr_dev, 0);
>>> +
>>> +_error_failed_reset_engine:
>>> +	hns_roce_free_cfg(hr_dev);
>>> +
>>> +_error_failed_get_cfg:
>>> +	ib_dealloc_device(&hr_dev->ib_dev);
>>> +
>>> +	return ret;
>>> +}
>> 
>> .
>> 
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
