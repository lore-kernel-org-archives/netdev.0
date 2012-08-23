From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 04/13] e1000e: cleanup checkpatch PREFER_PR_LEVEL
 warning
Date: Thu, 23 Aug 2012 07:01:44 -0700
Message-ID: <1345730504.16471.3.camel@joe2Laptop>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1345715813-20757-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Bruce Allan <bruce.w.allan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:57635 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030212Ab2HWOBq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 10:01:46 -0400
In-Reply-To: <1345715813-20757-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-23 at 02:56 -0700, Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> checkpatch warning: Prefer pr_info(... to printk(KERN_INFO, ...
[]
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
[]
> @@ -4330,9 +4330,8 @@ static void e1000_print_link_info(struct e1000_adapter *adapter)
>  	u32 ctrl = er32(CTRL);
>  
>  	/* Link status message must follow this format for user tools */
> -	printk(KERN_INFO "e1000e: %s NIC Link is Up %d Mbps %s Duplex, Flow Control: %s\n",
> -		adapter->netdev->name,
> -		adapter->link_speed,
> +	pr_info("e1000e: %s NIC Link is Up %d Mbps %s Duplex, Flow Control: %s\n",
> +		adapter->netdev->name, adapter->link_speed,
>  		adapter->link_duplex == FULL_DUPLEX ? "Full" : "Half",
>  		(ctrl & E1000_CTRL_TFCE) && (ctrl & E1000_CTRL_RFCE) ? "Rx/Tx" :
>  		(ctrl & E1000_CTRL_RFCE) ? "Rx" :

I think these conversions are not a good idea.

When you have a specific message format that must be
followed, use printk.

pr_<level> may at some point in the near future use
#define pr_fmt(fmt) KBUiLD_MODNAME ": " fmt
as a global default equivalent.
