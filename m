From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] lan78xx: add ndo_get_stats64
Date: Wed, 16 Mar 2016 17:16:30 +0300
Message-ID: <56E96ABE.1010206@cogentembedded.com>
References: <9235D6609DB808459E95D78E17F2E43D404C906A@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:33653 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966265AbcCPOQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 10:16:33 -0400
Received: by mail-lf0-f48.google.com with SMTP id h198so20263287lfh.0
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 07:16:32 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D404C906A@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/16/2016 1:52 AM, Woojung.Huh@microchip.com wrote:

> From: Woojung Huh <woojung.huh@microchip.com>
>
> Add lan78xx_get_stats64 of ndo_get_stats64 to report
> all statistics counters including errors from HW statistics.
>
> Read from HW when auto suspend is disabled, use saved counter when
> auto suspend is enabled because periodic call to ndo_get_stats64
> prevents USB auto suspend.
>
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> ---
>   drivers/net/usb/lan78xx.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 49 insertions(+)
>
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index f20890e..f4a9708f 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -3261,6 +3261,54 @@ void lan78xx_tx_timeout(struct net_device *net)
>   	tasklet_schedule(&dev->bh);
>   }
>
> +struct rtnl_link_stats64 *lan78xx_get_stats64(struct net_device *netdev,
> +					      struct rtnl_link_stats64 *storage)
> +{
[...]
> +	storage->rx_length_errors = (stats.rx_undersize_frame_errors +
> +				     stats.rx_oversize_frame_errors);

    Parens not needed.

> +	storage->rx_crc_errors = stats.rx_fcs_errors;
> +	storage->rx_frame_errors = stats.rx_alignment_errors;
> +	storage->rx_fifo_errors = stats.rx_dropped_frames;
> +	storage->rx_over_errors = stats.rx_oversize_frame_errors;
> +	storage->rx_errors = (stats.rx_fcs_errors +
> +			      stats.rx_alignment_errors +
> +			      stats.rx_fragment_errors +
> +			      stats.rx_jabber_errors +
> +			      stats.rx_undersize_frame_errors +
> +			      stats.rx_oversize_frame_errors +
> +			      stats.rx_dropped_frames);

    Neither here.

> +
> +	storage->tx_carrier_errors = stats.tx_carrier_errors;
> +	storage->tx_errors = (stats.tx_fcs_errors +
> +			      stats.tx_excess_deferral_errors +
> +			      stats.tx_carrier_errors);

    And here.

[...]

MBR, Sergei
