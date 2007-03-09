From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/5] NetXen: Update the statistics counter for interrupts
Date: Fri, 09 Mar 2007 08:25:23 -0800
Message-ID: <45F18A73.1080801@linux-foundation.org>
References: <200703090808.l2988A48011758@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38746 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767354AbXCIQZu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 11:25:50 -0500
In-Reply-To: <200703090808.l2988A48011758@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linsys Contractor Mithlesh Thukral wrote:
> NetXen: Update the statistics counter for interrupts which have occured.
>
> Signed-off-by: Mithlesh Thukral <mithlesh@netxen.com>
> ---
>
>  drivers/net/netxen/netxen_nic_main.c |    1 +
>  1 files changed, 1 insertion(+)
>
> diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
> index bfeca9a..5fbf6b0 100644
> --- a/drivers/net/netxen/netxen_nic_main.c
> +++ b/drivers/net/netxen/netxen_nic_main.c
> @@ -1023,6 +1023,7 @@ netxen_handle_int(struct netxen_adapter 
>  	u32 ret = 0;
>  
>  	DPRINTK(INFO, "Entered handle ISR\n");
> +	adapter->stats.ints++;
>  
>   
You may want to consider the cost of the additional cache miss.
Either don't bother with this stat, or go to per-cpu stats.
Plus isn't this already in the statistics kept for /proc/interrupts?
