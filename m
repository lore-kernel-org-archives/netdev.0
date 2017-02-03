From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 2/2] add one config to select relax order mode in
 intel NIC's Kconfig
Date: Fri, 3 Feb 2017 08:43:08 -0800
Message-ID: <CAKgT0UdxwTDwSsHKj5GfWTdNOcPdsnHBeM0mDxGoifDr8G1DYQ@mail.gmail.com>
References: <1486114233-9800-1-git-send-email-maowenan@huawei.com> <1486114233-9800-3-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Mao Wenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32812 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751131AbdBCQnO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 11:43:14 -0500
Received: by mail-io0-f194.google.com with SMTP id 101so2760103iom.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 08:43:14 -0800 (PST)
In-Reply-To: <1486114233-9800-3-git-send-email-maowenan@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 1:30 AM, Mao Wenan <maowenan@huawei.com> wrote:
> This patch allows one to enable relax order mode in intel NIC's
> Kconfig. CONFIG_ARCH_WANT_RELAX_ORDER is a common macro for some
> CPU architecture to use relax order mode in NIC's source codes.
> CONFIG_ARCH_WANT_RELAX_ORDER can be defined in arch/xxx/Kconfig,
> such as sparc system exists in arch/sparc/Kconfig, but not all
> of arm64 systems can use relax order mode, so it can't be defined
> in arch/arm64/Kconfig. Therefore PCI_RELAX_ORDER in NIC's Kconfig
> provide one way to define macro CONFIG_ARCH_WANT_RELAX_ORDER.
>
> Signed-off-by: Mao Wenan <maowenan@huawei.com>
> ---
>  drivers/net/ethernet/intel/Kconfig | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
> index 1349b45..b366722 100644
> --- a/drivers/net/ethernet/intel/Kconfig
> +++ b/drivers/net/ethernet/intel/Kconfig
> @@ -275,4 +275,19 @@ config FM10K
>           To compile this driver as a module, choose M here. The module
>           will be called fm10k.  MSI-X interrupt support is required
>
> +config PCI_RELAX_ORDER
> +        bool "PCI relax order mode support"
> +        default n
> +        select ARCH_WANT_RELAX_ORDER
> +        ---help---
> +          This allows one to enable relax order mode in driver.
> +          CONFIG_ARCH_WANT_RELAX_ORDER is a common macro for some
> +          CPU architecture to use relax order mode in NIC's source codes.
> +          CONFIG_ARCH_WANT_RELAX_ORDER can be defined in arch/xxx/Kconfig,
> +          such as sparc system exists in arch/sparc/Kconfig, but not all
> +          of arm64 systems can use relax order mode, so it can't be defined
> +          in arch/arm64/Kconfig. Therefore PCI_RELAX_ORDER provide one way
> +          to define macro CONFIG_ARCH_WANT_RELAX_ORDER. Say Y here if you
> +          want to enable relax order.
> +
>  endif # NET_VENDOR_INTEL


You can't be dropping configuration options like this in here.  The
ARCH_WANT_RELAX_ORDER should be selected by the architecture as a
def_bool, not by the user via a kconfig option.  In addition this
option has no business in the Intel wired LAN directory as this
impacts all architectures.

This is something that would be an architecture specific PCI option
and could impact other PCI devices beyond what is just in networking.
If you are wanting to target the arm64 architecture you should
probably drop this in the /arch/arm64/Kconfig, then that way anyone
familiar with the arm64 hardware can chime in if enabling relaxed
ordering causes any known issues.

- Alex
