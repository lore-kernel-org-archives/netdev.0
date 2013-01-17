From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 04/14] e1000e: add support for IEEE-1588 PTP
Date: Thu, 17 Jan 2013 16:35:35 +0100
Message-ID: <20130117153535.GA2937@netboy.at.omicron.at>
References: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1358422519-20981-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Bruce Allan <bruce.w.allan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:42828 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756558Ab3AQPfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 10:35:42 -0500
Received: by mail-wi0-f170.google.com with SMTP id hq7so4685292wib.5
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 07:35:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1358422519-20981-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 17, 2013 at 03:35:09AM -0800, Jeff Kirsher wrote:

> +static struct ptp_clock_info e1000e_ptp_clock_info = {
> +	.owner		= THIS_MODULE,

small nit: better to use a static string for .name here than ...

> +	.n_alarm	= 0,
> +	.n_ext_ts	= 0,
> +	.n_per_out	= 0,
> +	.pps		= 0,
> +	.adjfreq	= e1000e_phc_adjfreq,
> +	.adjtime	= e1000e_phc_adjtime,
> +	.gettime	= e1000e_phc_gettime,
> +	.settime	= e1000e_phc_settime,
> +	.enable		= e1000e_phc_enable,
> +};
> +
> +/**
> + * e1000e_ptp_init - initialize PTP for devices which support it
> + * @adapter: board private structure
> + *
> + * This function performs the required steps for enabling PTP support.
> + * If PTP support has already been loaded it simply calls the cyclecounter
> + * init routine and exits.
> + **/
> +void e1000e_ptp_init(struct e1000_adapter *adapter)
> +{
> +	struct e1000_hw *hw = &adapter->hw;
> +
> +	adapter->ptp_clock = NULL;
> +
> +	if (!(adapter->flags & FLAG_HAS_HW_TIMESTAMP))
> +		return;
> +
> +	adapter->ptp_clock_info = e1000e_ptp_clock_info;
> +
> +	snprintf(adapter->ptp_clock_info.name,
> +		 sizeof(adapter->ptp_clock_info.name), "%pm",
> +		 adapter->netdev->perm_addr);

... putting any kind of address here. After some back and forth,
discussing what the 'name' field should be, we decided on

 * @name:      A short "friendly name" to identify the clock and to
 *             help distinguish PHY based devices from MAC based ones.
 *             The string is not meant to be a unique id.

and most other drivers put the name of the driver here.

Other than that, this new driver looks good to me. I'll try it out
soon.

Acked-by: Richard Cochran <richardcochran@gmail.com>
