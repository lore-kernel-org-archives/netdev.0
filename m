From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V2 net-next 3/4] ptp: link the phc device to its parent
 device
Date: Sat, 22 Sep 2012 16:40:52 +0100
Message-ID: <1348328452.2521.78.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1348299094.git.richardcochran@gmail.com>
	 <847f89f4f5a2757c2487b23dac218e15613c2bb5.1348299094.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:27720 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751427Ab2IVPk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 11:40:58 -0400
In-Reply-To: <847f89f4f5a2757c2487b23dac218e15613c2bb5.1348299094.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-09-22 at 09:42 +0200, Richard Cochran wrote:
> PTP Hardware Clock devices appear as class devices in sysfs. This patch
> changes the registration API to use the parent device, clarifying the
> clock's relationship to the underlying device.
[...]
> --- a/drivers/net/ethernet/sfc/ptp.c
> +++ b/drivers/net/ethernet/sfc/ptp.c
> @@ -931,7 +931,8 @@ static int efx_ptp_probe_channel(struct efx_channel *channel)
>  	ptp->phc_clock_info.settime = efx_phc_settime;
>  	ptp->phc_clock_info.enable = efx_phc_enable;
>  
> -	ptp->phc_clock = ptp_clock_register(&ptp->phc_clock_info);
> +	ptp->phc_clock = ptp_clock_register(&ptp->phc_clock_info,
> +					    &channel->napi_dev->dev);
[...]

channel->napi_dev is the net device, not the PCI device.  The parent
device should be &efx->pci_dev->dev.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
