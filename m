From: Leon Romanovsky <leon@leon.nu>
Subject: Re: [PATCH 1/3] infiniband: IB/hns: add Hisilicon RoCE support
Date: Sat, 12 Mar 2016 12:39:40 +0200
Message-ID: <20160312103940.GA15703@leon.nu>
References: <1457692631-9290-1-git-send-email-oulijun@huawei.com>
 <1457692631-9290-2-git-send-email-oulijun@huawei.com>
Reply-To: leon@leon.nu
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gongyangming@huawei.com, xiaokun@huawei.com,
	tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	lisheng011@huawei.com, charles.chenxin@huawei.com,
	linuxarm@huawei.com
To: Lijun Ou <oulijun@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37537 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbcCLKyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 05:54:55 -0500
Received: by mail-wm0-f48.google.com with SMTP id p65so46632472wmp.0
        for <netdev@vger.kernel.org>; Sat, 12 Mar 2016 02:54:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1457692631-9290-2-git-send-email-oulijun@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2016 at 06:37:09PM +0800, Lijun Ou wrote:
> The driver for Hisilicon RoCE is a platform driver.
> The driver will support mulitple versions of hardware. Currently only "v1"
> for hip06 SOC is supported.
> The driver includes two parts: common driver and hardware-specific
> operations. hns_roce_v1_hw.c and hns_roce_v1_hw.h are files for
> hardware-specific operations only for v1 engine, and other files(.c and .h)
> for common algorithm and common hardware operations
> 
> Signed-off-by: Lijun Ou <oulijun@huawei.com>
> Signed-off-by: Wei Hu(Xavier) <xavier.huwei@huawei.com>
> Signed-off-by: Znlong <zhaonenglong@huawei.com>
> ---
>  drivers/infiniband/Kconfig                         |    2 +-
>  drivers/infiniband/hw/Makefile                     |    1 +
>  drivers/infiniband/hw/hisilicon/hns/Kconfig        |   10 +
>  drivers/infiniband/hw/hisilicon/hns/Makefile       |    9 +
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c  |  114 +
>  .../infiniband/hw/hisilicon/hns/hns_roce_alloc.c   |  253 ++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c |  354 +++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h |  163 ++
>  .../infiniband/hw/hisilicon/hns/hns_roce_common.h  |  704 +++++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c  |  454 +++
>  .../infiniband/hw/hisilicon/hns/hns_roce_device.h  |  840 ++++++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c  |  798 ++++++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h  |  138 +
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c |  608 ++++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h |  121 +
>  .../infiniband/hw/hisilicon/hns/hns_roce_main.c    | 1124 ++++++++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c  |  637 +++++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c  |  129 +
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c  |  890 ++++++
>  .../infiniband/hw/hisilicon/hns/hns_roce_user.h    |   31 +
>  .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c   | 2992 ++++++++++++++++++++
>  .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h   | 1068 +++++++
>  22 files changed, 11439 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/Kconfig
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/Makefile
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_alloc.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_common.h
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_device.h
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_main.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_user.h
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h
> 
> diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
> index 8a8440c..c7a24bb 100644
> --- a/drivers/infiniband/Kconfig
> +++ b/drivers/infiniband/Kconfig
> @@ -73,7 +73,7 @@ source "drivers/infiniband/hw/mlx5/Kconfig"
>  source "drivers/infiniband/hw/nes/Kconfig"
>  source "drivers/infiniband/hw/ocrdma/Kconfig"
>  source "drivers/infiniband/hw/usnic/Kconfig"
> -

No need to remove this line. It separates HW from ULPs.

> +source "drivers/infiniband/hw/hisilicon/hns/Kconfig"
>  source "drivers/infiniband/ulp/ipoib/Kconfig"
>  
>  source "drivers/infiniband/ulp/srp/Kconfig"

<snip>

> +int hns_roce_bitmap_alloc_range(
> +					struct hns_roce_bitmap *bitmap,
> +					int cnt, int align, u32 *obj)

You have indentation issues.

> +{
> +	int i;
> +	int ret = 0;
> +
> +	if (likely(cnt == 1 && align == 1))
> +		return hns_roce_bitmap_alloc(bitmap, obj);
> +
> +	spin_lock(&bitmap->lock);
> +
> +	*obj = bitmap_find_next_zero_area(bitmap->table, bitmap->max,
> +					  bitmap->last, cnt, align - 1);
> +	if (*obj >= bitmap->max) {
> +		bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
> +			       & bitmap->mask;
> +		*obj = bitmap_find_next_zero_area(bitmap->table, bitmap->max, 0,
> +						  cnt, align - 1);
> +	}
> +
> +	if (*obj < bitmap->max) {
> +		for (i = 0; i < cnt; i++)
> +			set_bit(*obj + i, bitmap->table);
> +
> +		if (*obj == bitmap->last) {
> +			bitmap->last = (*obj + cnt);
> +			if (bitmap->last >= bitmap->max)
> +				bitmap->last = 0;
> +		}
> +		*obj |= bitmap->top;
> +	} else {
> +		ret = -1;
> +	}
> +
> +	spin_unlock(&bitmap->lock);
> +
> +	return ret;
> +}
> +
> +void hns_roce_bitmap_free_range(
> +					struct hns_roce_bitmap *bitmap,
> +					u32 obj,
> +					int cnt)
> +{
> +	int i;
> +
> +	obj &= bitmap->max + bitmap->reserved_top - 1;
> +
> +	spin_lock(&bitmap->lock);
> +	for (i = 0; i < cnt; i++)
> +		clear_bit(obj + i, bitmap->table);
> +
> +	bitmap->last = min(bitmap->last, obj);
> +	bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
> +		       & bitmap->mask;
> +	spin_unlock(&bitmap->lock);
> +}
> +
> +int hns_roce_bitmap_init(struct hns_roce_bitmap *bitmap, u32 num,
> +			       u32 mask, u32 reserved_bot,
> +			       u32 reserved_top)
> +{
> +	u32 i;
> +
> +	if (num != roundup_pow_of_two(num))
> +		return -EINVAL;
> +
> +	bitmap->last = 0;
> +	bitmap->top  = 0;
> +	bitmap->max  = num - reserved_top;
> +	bitmap->mask = mask;
> +	bitmap->reserved_top = reserved_top;
> +	spin_lock_init(&bitmap->lock);
> +	bitmap->table =
> +		kzalloc(BITS_TO_LONGS(bitmap->max) * sizeof(long), GFP_KERNEL);

Here and below, please consider to use kcalloc.

> +	if (!bitmap->table)
> +		return -ENOMEM;
> +
> +	for (i = 0; i < reserved_bot; ++i)
