From: Dan Williams <dcbw@redhat.com>
Subject: Re: [NET-NEXT PATCH 08/14] e1000e: link up/down messages must
	follow a specific format
Date: Fri, 21 Nov 2008 14:04:55 -0500
Message-ID: <1227294295.23438.17.camel@localhost.localdomain>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
	 <20081121190110.32313.43591.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	Bruce Allan <bruce.w.allan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46200 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754683AbYKUTFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 14:05:41 -0500
In-Reply-To: <20081121190110.32313.43591.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-11-21 at 11:01 -0800, Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The system log messages created on a link status change need to follow a
> specific format to work with tools some customers use.

Um, shouldn't those tools be listening to netlink for carrier events, or
are these tools run on a separate machine using on some later date using
the logs from the machine with the e1000e?

Dan

> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/e1000e/netdev.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 7eb1a36..cd6d132 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -3408,7 +3408,10 @@ static void e1000_print_link_info(struct e1000_adapter *adapter)
>  	struct e1000_hw *hw = &adapter->hw;
>  	u32 ctrl = er32(CTRL);
>  
> -	e_info("Link is Up %d Mbps %s, Flow Control: %s\n",
> +	/* Link status message must follow this format for user tools */
> +	printk(KERN_INFO "e1000e: %s NIC Link is Up %d Mbps %s, "
> +	       "Flow Control: %s\n",
> +	       adapter->netdev->name,
>  	       adapter->link_speed,
>  	       (adapter->link_duplex == FULL_DUPLEX) ?
>  	                        "Full Duplex" : "Half Duplex",
> @@ -3618,7 +3621,9 @@ static void e1000_watchdog_task(struct work_struct *work)
>  		if (netif_carrier_ok(netdev)) {
>  			adapter->link_speed = 0;
>  			adapter->link_duplex = 0;
> -			e_info("Link is Down\n");
> +			/* Link status message must follow this format */
> +			printk(KERN_INFO "e1000e: %s NIC Link is Down\n",
> +			       adapter->netdev->name);
>  			netif_carrier_off(netdev);
>  			netif_tx_stop_all_queues(netdev);
>  			if (!test_bit(__E1000_DOWN, &adapter->state))
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

