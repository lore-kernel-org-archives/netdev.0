From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH 1/2] xen/netfront: set default upper limit of tx/rx queues
 to 8
Date: Tue, 10 Jan 2017 09:53:44 -0500
Message-ID: <3ae4da4f-6a6a-db95-67a3-c0fba5524df1@oracle.com>
References: <20170110133252.5346-1-jgross@suse.com>
 <20170110133252.5346-2-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, paul.durrant@citrix.com
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org,
        xen-devel@lists.xenproject.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44309 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757926AbdAJOxp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 09:53:45 -0500
In-Reply-To: <20170110133252.5346-2-jgross@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2017 08:32 AM, Juergen Gross wrote:
> The default for the number of tx/rx queues of one interface is the
> number of vcpus of the system today. As each queue pair reserves 512
> grant pages this default consumes a ridiculous number of grants for
> large guests.
>
> Limit the queue number to 8 as default. This value can be modified
> via a module parameter if required.
>
> Signed-off-by: Juergen Gross <jgross@suse.com>
> ---
>  drivers/net/xen-netfront.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index a479cd9..490c865 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -57,6 +57,7 @@
>  #include <xen/interface/grant_table.h>
>  
>  /* Module parameters */
> +#define MAX_QUEUES_DEFAULT 8
>  static unsigned int xennet_max_queues;
>  module_param_named(max_queues, xennet_max_queues, uint, 0644);
>  MODULE_PARM_DESC(max_queues,
> @@ -2164,11 +2165,12 @@ static int __init netif_init(void)
>  
>  	pr_info("Initialising Xen virtual ethernet driver\n");
>  
> -	/* Allow as many queues as there are CPUs if user has not
> +	/* Allow as many queues as there are CPUs inut max. 8 if user has not

Based on comment change in the second patch: s/inut/but/ ? Also, comment
style in both patches.

Other than that, for both:

Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>


>  	 * specified a value.
>  	 */
>  	if (xennet_max_queues == 0)
> -		xennet_max_queues = num_online_cpus();
> +		xennet_max_queues = min_t(unsigned int, MAX_QUEUES_DEFAULT,
> +					  num_online_cpus());
>  
>  	return xenbus_register_frontend(&netfront_driver);
>  }
