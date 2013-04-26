From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net 6/7] qlcnic: Fix reset recovery after transmit
 timeout
Date: Fri, 26 Apr 2013 22:01:01 +0100
Message-ID: <1367010061.4035.7.camel@bwh-desktop.uk.solarflarecom.com>
References: <1366978183-7282-1-git-send-email-shahed.shaikh@qlogic.com>
	 <1366978183-7282-7-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63166 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756535Ab3DZVBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 17:01:05 -0400
In-Reply-To: <1366978183-7282-7-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-26 at 08:09 -0400, Shahed Shaikh wrote:
> From: Sony Chacko <sony.chacko@qlogic.com>
> 
> o When transmit timeout happens, recovery attempt should start with
>   adapter soft reset. If soft reset fails to resume traffic, firmware
>   dump will be collected and driver will perform a hard reset of the
>   adapter. Reset recovery on 83xx was failing after a hard reset.
>   This patch fixes that issue.
> 
> Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
> ---
>  .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   24 ++++++++++++-------
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   15 ++++++++----
>  2 files changed, 25 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
> index 5c033f2..7b103d1 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
> @@ -406,10 +406,7 @@ static void qlcnic_83xx_idc_attach_driver(struct qlcnic_adapter *adapter)
>  	}
>  done:
>  	netif_device_attach(netdev);
> -	if (netif_running(netdev)) {
> -		netif_carrier_on(netdev);
> -		netif_wake_queue(netdev);
> -	}
> +	adapter->netdev->trans_start = jiffies;
>  }
[...]

The deletions look good, but it should not be necessary to write to
trans_start.  Why do you think it is needed?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
