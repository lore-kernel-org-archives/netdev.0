From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 1/8] netback: don't bind kthread to cpu
Date: Mon, 4 Mar 2013 15:51:54 -0500
Message-ID: <20130304205154.GB16762@phenom.dumpdata.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
 <1360944010-15336-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, annie.li@oracle.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39635 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758717Ab3CDUwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 15:52:02 -0500
Content-Disposition: inline
In-Reply-To: <1360944010-15336-2-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 15, 2013 at 04:00:02PM +0000, Wei Liu wrote:
> The initialization process makes an assumption that the online cpus are
> numbered from 0 to xen_netbk_group_nr-1,  which is not always true.

And xen_netbk_group_nr is num_online_cpus()?

So under what conditions does this change? Is this when the CPU hotplug
is involved and the CPUs go offline? In which case should there be a
CPU hotplug notifier to re-bind the workers are appropiate?

> 
> As we only need a pool of worker threads, simply don't bind them to specific
> cpus.

OK. Is there another method of doing this? Are there patches to make the thread
try to be vCPU->guest affinite?

> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netback/netback.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 3ae49b1..db8d45a 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1729,8 +1729,6 @@ static int __init netback_init(void)
>  			goto failed_init;
>  		}
>  
> -		kthread_bind(netbk->task, group);
> -
>  		INIT_LIST_HEAD(&netbk->net_schedule_list);
>  
>  		spin_lock_init(&netbk->net_schedule_list_lock);
> -- 
> 1.7.10.4
> 
