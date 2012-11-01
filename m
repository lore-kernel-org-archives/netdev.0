From: Bob Liu <lliubbo@gmail.com>
Subject: Re: [PATCH V2 net-next 1/4] bfin_mac: only advertise hardware time
 stamped when enabled.
Date: Thu, 1 Nov 2012 17:40:11 +0800
Message-ID: <CAA_GA1cfc66Sh+ojPyEjc8vHJgVxoEWj=kbAywv-Pm0-R5v1yg@mail.gmail.com>
References: <cover.1351696541.git.richardcochran@gmail.com>
	<e9f363ffac9c59b5174b4bf89a157e0dfeb151bb.1351696541.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, device-drivers-devel@blackfin.uclinux.org,
	uclinux-dist-devel@blackfin.uclinux.org,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Sonic Zhang <sonic.zhang@analog.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:35597 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932645Ab2KAJkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 05:40:13 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so1576724wgb.1
        for <netdev@vger.kernel.org>; Thu, 01 Nov 2012 02:40:11 -0700 (PDT)
In-Reply-To: <e9f363ffac9c59b5174b4bf89a157e0dfeb151bb.1351696541.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 1, 2012 at 12:27 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> The hardware time stamping code is a compile time option for the blackfin.
> When it is not enabled, the driver should fall back to the standard
> ethtool reply to the get_ts_info query.
>
> Compile tested only.
>
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Tested-by: Bob Liu <lliubbo@gmail.com>

> ---
>  drivers/net/ethernet/adi/bfin_mac.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
> index f816426..2349abb 100644
> --- a/drivers/net/ethernet/adi/bfin_mac.c
> +++ b/drivers/net/ethernet/adi/bfin_mac.c
> @@ -548,6 +548,7 @@ static int bfin_mac_ethtool_setwol(struct net_device *dev,
>         return 0;
>  }
>
> +#ifdef CONFIG_BFIN_MAC_USE_HWSTAMP
>  static int bfin_mac_ethtool_get_ts_info(struct net_device *dev,
>         struct ethtool_ts_info *info)
>  {
> @@ -566,6 +567,7 @@ static int bfin_mac_ethtool_get_ts_info(struct net_device *dev,
>                 (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT);
>         return 0;
>  }
> +#endif
>
>  static const struct ethtool_ops bfin_mac_ethtool_ops = {
>         .get_settings = bfin_mac_ethtool_getsettings,
> @@ -574,7 +576,9 @@ static const struct ethtool_ops bfin_mac_ethtool_ops = {
>         .get_drvinfo = bfin_mac_ethtool_getdrvinfo,
>         .get_wol = bfin_mac_ethtool_getwol,
>         .set_wol = bfin_mac_ethtool_setwol,
> +#ifdef CONFIG_BFIN_MAC_USE_HWSTAMP
>         .get_ts_info = bfin_mac_ethtool_get_ts_info,
> +#endif
>  };
>
>  /**************************************************************************/
> --
> 1.7.2.5
>

-- 
Regards,
--Bob
