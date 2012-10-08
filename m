From: Haicheng Li <haicheng.li@linux.intel.com>
Subject: Re: [PATCH] pch_pge: Fix build error by selecting all the possible
 dependencies.
Date: Mon, 08 Oct 2012 19:15:12 +0800
Message-ID: <5072B5C0.4010309@linux.intel.com>
References: <20121006075954.GA29618@localhost> <1349670580-11158-1-git-send-email-haicheng.lee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, haicheng.li@linux.jf.intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	fengguang.wu@intel.com
To: Haicheng Li <haicheng.lee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349670580-11158-1-git-send-email-haicheng.lee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just realized a typo in the subject, pls. ignore this. will send a new soon. 
sorry.

On 10/08/2012 12:29 PM, Haicheng Li wrote:
> Fengguang reported a kernel build failure as folowing:
> drivers/built-in.o: In function `pch_gbe_ioctl':
> pch_gbe_main.c:(.text+0x510370): undefined reference to `pch_ch_control_write'
> pch_gbe_main.c:(.text+0x510393): undefined reference to `pch_ch_control_write'
> pch_gbe_main.c:(.text+0x5103b3): undefined reference to `pch_ch_control_write'
> ..
>
> It's a regression by commit da1586461. The root cause is that
> the CONFIG_PPS is not set there, consequently CONFIG_PTP_1588_CLOCK
> can not be set anyway, which finally causes ptp_pch and pch_gbe_main
> build failures.
>
> As David prefers to use *select* to fix such module co-dependency issues,
> this patch explicitly selects all the possible dependencies of PCH_PTP.
>
> Reported-by: Fengguang Wu<fengguang.wu@intel.com>
> Reviewed-by: David S. Miller<davem@davemloft.net>
> Signed-off-by: Haicheng Li<haicheng.lee@gmail.com>
> ---
>   drivers/net/ethernet/oki-semi/pch_gbe/Kconfig |    3 +++
>   1 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
> index 9730241..5296cc8 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
> @@ -26,6 +26,9 @@ if PCH_GBE
>   config PCH_PTP
>   	bool "PCH PTP clock support"
>   	default n
> +	depends on EXPERIMENTAL
> +	select PPS
> +	select PTP_1588_CLOCK
>   	select PTP_1588_CLOCK_PCH
>   	---help---
>   	  Say Y here if you want to use Precision Time Protocol (PTP) in the
