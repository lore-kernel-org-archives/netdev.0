From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH 0732/1285] Replace numeric parameter like 0444 with macro
Date: Tue, 2 Aug 2016 13:34:13 +0100
Message-ID: <febfc335-ad2f-84f1-3289-327c95c1ef8d@solarflare.com>
References: <20160802114053.30858-1-baolex.ni@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>, <bkenward@solarflare.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Baole Ni <baolex.ni@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:30482 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934881AbcHBMjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 08:39:06 -0400
In-Reply-To: <20160802114053.30858-1-baolex.ni@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/16 12:40, Baole Ni wrote:
> I find that the developers often just specified the numeric value
> when calling a macro which is defined with a parameter for access permission.
> As we know, these numeric value for access permission have had the corresponding macro,
> and that using macro can improve the robustness and readability of the code,
> thus, I suggest replacing the numeric parameter with the macro.
NAK.  To anyone with enough Unix experience to be contributing to the kernel,
the octal values are *easier* to read: they're compact, and usually just take
one of a few stereotyped values anyway (mostly 0444 or 0644).  The macros are
full of fluffy noise and take longer to read.
(Also, if you're sending a 1,285-patch series, you should probably reconsider
the choices that have brought you to this point.)
-Ed
> Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
> Signed-off-by: Baole Ni <baolex.ni@intel.com>
> ---
>  drivers/net/ethernet/sfc/ef10.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
> index 1f30912..fcf06c5 100644
> --- a/drivers/net/ethernet/sfc/ef10.c
> +++ b/drivers/net/ethernet/sfc/ef10.c
> @@ -275,9 +275,9 @@ static ssize_t efx_ef10_show_primary_flag(struct device *dev,
>  		       ? 1 : 0);
>  }
>  
> -static DEVICE_ATTR(link_control_flag, 0444, efx_ef10_show_link_control_flag,
> +static DEVICE_ATTR(link_control_flag, S_IRUSR | S_IRGRP | S_IROTH, efx_ef10_show_link_control_flag,
>  		   NULL);
> -static DEVICE_ATTR(primary_flag, 0444, efx_ef10_show_primary_flag, NULL);
> +static DEVICE_ATTR(primary_flag, S_IRUSR | S_IRGRP | S_IROTH, efx_ef10_show_primary_flag, NULL);
>  
>  static int efx_ef10_probe(struct efx_nic *efx)
>  {
