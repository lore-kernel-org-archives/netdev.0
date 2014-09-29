From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 3/4] ptp: Add PTP_PF_PPS enumeration to
 ptp_pin_function.
Date: Mon, 29 Sep 2014 10:56:14 +0200
Message-ID: <20140929085613.GA9891@netboy>
References: <1411878011-21767-1-git-send-email-b45643@freescale.com>
 <1411878011-21767-4-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, shawn.guo@linaro.org,
	bhutchings@solarflare.com, R49496@freescale.com,
	b38611@freescale.com, b20596@freescale.com,
	stephen@networkplumber.org
To: Luwei Zhou <b45643@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:60078 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbaI2I4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 04:56:19 -0400
Received: by mail-wi0-f180.google.com with SMTP id em10so461498wid.13
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 01:56:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1411878011-21767-4-git-send-email-b45643@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 28, 2014 at 12:20:10PM +0800, Luwei Zhou wrote:

> diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
> index 0d8ff3f..2a5ad1c 100644
> --- a/include/linux/ptp_clock_kernel.h
> +++ b/include/linux/ptp_clock_kernel.h
> @@ -49,6 +49,7 @@ struct ptp_clock_request {
>   * @n_alarm:   The number of programmable alarms.
>   * @n_ext_ts:  The number of external time stamp channels.
>   * @n_per_out: The number of programmable periodic signals.
> + * @n_pps_chan: The number of programmable channles for pps output.
>   * @n_pins:    The number of programmable pins.
>   * @pps:       Indicates whether the clock supports a PPS callback.
>   * @pin_config: Array of length 'n_pins'. If the number of
> @@ -99,6 +100,7 @@ struct ptp_clock_info {
>  	int n_alarm;
>  	int n_ext_ts;
>  	int n_per_out;
> +	int n_pps_chan;

We don't need this. There is only *one* PPS channel.

We only want to select which of 'n_pins' will be the PPS output.

>  	int n_pins;
>  	int pps;
>  	struct ptp_pin_desc *pin_config;
> diff --git a/include/uapi/linux/ptp_clock.h b/include/uapi/linux/ptp_clock.h
> index f0b7bfe..57ba7e7 100644
> --- a/include/uapi/linux/ptp_clock.h
> +++ b/include/uapi/linux/ptp_clock.h
> @@ -86,6 +86,7 @@ enum ptp_pin_function {
>  	PTP_PF_EXTTS,
>  	PTP_PF_PEROUT,
>  	PTP_PF_PHYSYNC,
> +	PTP_PF_PPS,
>  };
>  
>  struct ptp_pin_desc {
> -- 
> 1.9.1
> 

Thanks,
Richard
