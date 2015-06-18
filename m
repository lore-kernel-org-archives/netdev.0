From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 02/22] fjes: Hardware initialization routine
Date: Wed, 17 Jun 2015 18:57:34 -0700
Message-ID: <1434592654.2689.93.camel@perches.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
	 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
	 <1434588587-25655-2-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1434588587-25655-2-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-06-18 at 09:49 +0900, Taku Izumi wrote:
> This patch adds hardware initialization routine to be
> invoked at driver's .probe routine.

Trivial notes:

Please run all your patches through scripts/checkpatch.pl and
fix whatever messages it emits as you think appropriate.

> diff --git a/drivers/platform/x86/fjes/fjes_hw.c b/drivers/platform/x86/fjes/fjes_hw.c
[]
> +/* supported MTU list */
> +u32 fjes_support_mtu[] = {
> +	FJES_MTU_DEFINE(8 * 1024),
> +	FJES_MTU_DEFINE(16 * 1024),
> +	FJES_MTU_DEFINE(32 * 1024),
> +	FJES_MTU_DEFINE(64 * 1024),
> +	0
> +};

Maybe these should be const?

> +static u8 *fjes_hw_iomap(struct fjes_hw *hw)
> +{
> +	u8 *base;
> +
> +	if (!request_mem_region(hw->hw_res.start, hw->hw_res.size,
> +			fjes_driver_name)) {
> +		pr_err("request_mem_region failed");

Please make sure all pr_<level> logging messages end with a "\n"
so that interleaving by other process threads can't happen.

> +static int fjes_hw_setup(struct fjes_hw *hw)
> +{
[]
> +	mem_size = sizeof(struct ep_share_mem_info) * (hw->max_epid);
> +	buf = kzalloc(mem_size, GFP_KERNEL);

kcalloc?

[]

> +	memset((void *)&param, 0, sizeof(param));

Unnecessary cast

> diff --git a/drivers/platform/x86/fjes/fjes_hw.h b/drivers/platform/x86/fjes/fjes_hw.h
[]
> +#define FJES_DEVICE_RESET_TIMEOUT  ((17 + 1) * 3) /* sec */

48 second timeout for a device reset?

> +/* Frame & MTU */
> +struct esmem_frame_t {
> +	__le32 frame_size;
> +	u8 frame_data[];
> +};

Using a _t suffix for a struct type can be confusing.

[]
> +	struct _ep_buffer_info_common_t {
> +		u32 version;
> +	} common;
> +
> +	struct _ep_buffer_info_v1_t {

> diff --git a/drivers/platform/x86/fjes/fjes_regs.h b/drivers/platform/x86/fjes/fjes_regs.h

> +/* Interrupt Control registers */
> +#define XSCT_IMS            0x0084  /* Interrupt mas set */

mask

> +#define XSCT_IMC            0x0088  /* Interrupt mask clear */
