From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 09/15] e1000e: resolve checkpatch PREFER_PR_LEVEL
 warning
Date: Fri, 11 Jan 2013 09:03:39 -0800
Message-ID: <1357923819.2327.5.camel@joe-AO722>
References: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1357899831-4168-10-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Bruce Allan <bruce.w.allan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60258 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754511Ab3AKRDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 12:03:38 -0500
In-Reply-To: <1357899831-4168-10-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-11 at 02:23 -0800, Jeff Kirsher wrote:
> WARNING: Prefer netdev_info(netdev, ... then dev_info(dev, ...
> then pr_info(...  to printk(KERN_INFO ...
[]
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
[]
> @@ -4300,9 +4300,8 @@ static void e1000_print_link_info(struct e1000_adapter *adapter)
>  	u32 ctrl = er32(CTRL);
>  
>  	/* Link status message must follow this format for user tools */
> -	printk(KERN_INFO "e1000e: %s NIC Link is Up %d Mbps %s Duplex, Flow Control: %s\n",
> -		adapter->netdev->name,
> -		adapter->link_speed,
> +	pr_info("e1000e: %s NIC Link is Up %d Mbps %s Duplex, Flow Control: %s\n",
> +		adapter->netdev->name, adapter->link_speed,

Don't these changes break a user-space tool?

If not, please remove the comment above the pr_info()s
and remove the unnecessary e1000e: prefixes.

> @@ -4521,8 +4520,8 @@ static void e1000_watchdog_task(struct work_struct *work)
[]
>  			/* Link status message must follow this format */
> -			printk(KERN_INFO "e1000e: %s NIC Link is Down\n",
> -			       adapter->netdev->name);
> +			pr_info("e1000e: %s NIC Link is Down\n",
> +				adapter->netdev->name);
