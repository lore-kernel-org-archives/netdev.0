From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] net:add one common config ARCH_WANT_RELAX_ORDER
 to support relax ordering.
Date: Fri, 6 Jan 2017 07:41:14 -0800
Message-ID: <CAKgT0Uencn48k69UYt24B75O--5GL9pC-haYh4do4rxeN4pYgA@mail.gmail.com>
References: <1483696364-8680-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Mao Wenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34098 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965303AbdAFPlP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 10:41:15 -0500
Received: by mail-it0-f68.google.com with SMTP id q186so2418122itb.1
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 07:41:15 -0800 (PST)
In-Reply-To: <1483696364-8680-1-git-send-email-maowenan@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 6, 2017 at 1:52 AM, Mao Wenan <maowenan@huawei.com> wrote:
> Relax ordering(RO) is one feature of 82599 NIC, to enable this feature can
> enhance the performance for some cpu architecure, such as SPARC and so on.
> Currently it only supports one special cpu architecture(SPARC) in 82599
> driver to enable RO feature, this is not very common for other cpu architecture
> which really needs RO feature.
> This patch add one common config CONFIG_ARCH_WANT_RELAX_ORDER to set RO feature,
> and should define CONFIG_ARCH_WANT_RELAX_ORDER in sparc Kconfig firstly.
>
> Signed-off-by: Mao Wenan <maowenan@huawei.com>
> ---
>  arch/sparc/Kconfig                              | 1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 2 +-
>  2 files changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
> index cf4034c..68ac5c7 100644
> --- a/arch/sparc/Kconfig
> +++ b/arch/sparc/Kconfig
> @@ -44,6 +44,7 @@ config SPARC
>         select CPU_NO_EFFICIENT_FFS
>         select HAVE_ARCH_HARDENED_USERCOPY
>         select PROVE_LOCKING_SMALL if PROVE_LOCKING
> +       select ARCH_WANT_RELAX_ORDER
>
>  config SPARC32
>         def_bool !64BIT


I'm pretty sure this is incomplete.  I think you need to add a couple
lines to arch/Kconfig so that the config option itself is listed
somewhere.  You might look at using something like HAVE_CMPXCHG_DOUBLE
as an example.

- Alex
