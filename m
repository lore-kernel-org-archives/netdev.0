From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net v3 2/2] xen-netfront: respect user provided
 max_queues
Date: Thu, 10 Sep 2015 14:35:17 +0100
Message-ID: <55F18715.5000808@citrix.com>
References: <1441880338-4911-1-git-send-email-wei.liu2@citrix.com>
 <1441880338-4911-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>,
	Xen-devel <xen-devel@lists.xenproject.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:2184 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446AbbIJNfV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2015 09:35:21 -0400
In-Reply-To: <1441880338-4911-3-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/15 11:18, Wei Liu wrote:
> Originally that parameter was always reset to num_online_cpus during
> module initialisation, which renders it useless.
> 
> The fix is to only set max_queues to num_online_cpus when user has not
> provided a value.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>
Tested-by: David Vrabel <david.vrabel@citrix.com>

David

> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -2132,8 +2132,11 @@ static int __init netif_init(void)
>  
>  	pr_info("Initialising Xen virtual ethernet driver\n");
>  
> -	/* Allow as many queues as there are CPUs, by default */
> -	xennet_max_queues = num_online_cpus();
> +	/* Allow as many queues as there are CPUs if user has not
> +	 * specified a value.
> +	 */
> +	if (xennet_max_queues == 0)
> +		xennet_max_queues = num_online_cpus();
>  
>  	return xenbus_register_frontend(&netfront_driver);
>  }
> 
