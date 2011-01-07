From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 03/12] e1000e: properly bounds-check string functions
Date: Fri, 07 Jan 2011 00:48:08 +0000
Message-ID: <1294361288.11825.65.camel@bwh-desktop>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1294360199-9860-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Bruce Allan <bruce.w.allan@intel.com>,
	netdev@vger.kernel.org, gosp@redhat.com, bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27374 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754946Ab1AGAsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 19:48:11 -0500
In-Reply-To: <1294360199-9860-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-01-06 at 16:29 -0800, jeffrey.t.kirsher@intel.com wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Use string functions with bounds checking rather than their non-bounds
> checking counterparts, and do not hard code these boundaries.
[...]
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
[...]
> @@ -5968,7 +5968,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
>  	if (!(adapter->flags & FLAG_HAS_AMT))
>  		e1000_get_hw_control(adapter);
>  
> -	strcpy(netdev->name, "eth%d");
> +	strncpy(netdev->name, "eth%d", sizeof(netdev->name) - 1);
>  	err = register_netdev(netdev);
>  	if (err)
>  		goto err_register;
[...]

This statement is actually redundant - alloc_etherdev() sets the name
for you.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

