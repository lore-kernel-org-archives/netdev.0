From: maowenan <maowenan@huawei.com>
Subject: RE: [PATCH v2 net-next] net:add one common config
 ARCH_WANT_RELAX_ORDER to support relax ordering.
Date: Mon, 9 Jan 2017 12:07:03 +0000
Message-ID: <F95AC9340317A84688A5F0DF0246F3F201EC4E06@szxemi502-mbx.china.huawei.com>
References: <1483939954-9864-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dingtianhong <dingtianhong@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>
To: maowenan <maowenan@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:45054 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760025AbdAIMHP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 07:07:15 -0500
In-Reply-To: <1483939954-9864-1-git-send-email-maowenan@huawei.com>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Mao Wenan
> Sent: Monday, January 09, 2017 1:33 PM
> To: netdev@vger.kernel.org; jeffrey.t.kirsher@intel.com;
> alexander.duyck@gmail.com
> Subject: [PATCH v2 net-next] net:add one common config
> ARCH_WANT_RELAX_ORDER to support relax ordering.
> 
> Relax ordering(RO) is one feature of 82599 NIC, to enable this feature can
> enhance the performance for some cpu architecure, such as SPARC and so on.
> Currently it only supports one special cpu architecture(SPARC) in 82599 driver
> to enable RO feature, this is not very common for other cpu architecture which
> really needs RO feature.
> This patch add one common config CONFIG_ARCH_WANT_RELAX_ORDER to
> set RO feature, and should define CONFIG_ARCH_WANT_RELAX_ORDER in
> sparc Kconfig firstly.
> 
> Signed-off-by: Mao Wenan <maowenan@huawei.com>
> ---
>  arch/Kconfig                                    | 3 +++
>  arch/sparc/Kconfig                              | 1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 2 +-
>  3 files changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/Kconfig b/arch/Kconfig index 99839c2..bd04eac 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -781,4 +781,7 @@ config VMAP_STACK
>  	  the stack to map directly to the KASAN shadow map using a formula
>  	  that is incorrect if the stack is in vmalloc space.
> 
> +config ARCH_WANT_RELAX_ORDER
> +	bool
> +
>  source "kernel/gcov/Kconfig"
> diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig index cf4034c..68ac5c7
> 100644
> --- a/arch/sparc/Kconfig
> +++ b/arch/sparc/Kconfig
> @@ -44,6 +44,7 @@ config SPARC
>  	select CPU_NO_EFFICIENT_FFS
>  	select HAVE_ARCH_HARDENED_USERCOPY
>  	select PROVE_LOCKING_SMALL if PROVE_LOCKING
> +	select ARCH_WANT_RELAX_ORDER
> 
>  config SPARC32
>  	def_bool !64BIT
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> index 094e1d6..c38d50c 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> @@ -350,7 +350,7 @@ s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
>  	}
>  	IXGBE_WRITE_FLUSH(hw);
> 
> -#ifndef CONFIG_SPARC
> +#ifndef CONFIG_ARCH_WANT_RELAX_ORDER
>  	/* Disable relaxed ordering */
>  	for (i = 0; i < hw->mac.max_tx_queues; i++) {
>  		u32 regval;
> --
> 2.7.0
> 

Hi Alex, Is there any improvement for this patch?
@Jeff, do you have any comments about this patch?
