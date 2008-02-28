From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/15] [NETFILTER]: Use proc_create() to setup
 ->proc_fops first
Date: Thu, 28 Feb 2008 14:05:30 -0800 (PST)
Message-ID: <20080228.140530.00362906.davem@davemloft.net>
References: <47C69348.5090400@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51589
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758497AbYB1WFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 17:05:30 -0500
In-Reply-To: <47C69348.5090400@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 28 Feb 2008 18:56:08 +0800

> Use proc_create() and proc_net_fops_create() to
> make sure that ->proc_fops be setup before gluing
> PDE to main tree.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

I'll forward this to Patrick McHardy and netfilter-devel.
Please submit netfilter changes that way in the future.

> @@ -588,10 +588,10 @@ static int __init ip_queue_init(void)
>  	}
>  
>  #ifdef CONFIG_PROC_FS
> -	proc = create_proc_entry(IPQ_PROC_FS_NAME, 0, init_net.proc_net);
> +	proc = proc_net_fops_create(&init_net, IPQ_PROC_FS_NAME,
> +				    0, &ip_queue_proc_fops);
>  	if (proc) {
>  		proc->owner = THIS_MODULE;
> -		proc->proc_fops = &ip_queue_proc_fops;
>  	} else {
>  		printk(KERN_ERR "ip_queue: failed to create proc entry\n");
>  		goto cleanup_ipqnl;

Doesn't ->owner have the same visibility problems that
->proc_fops does?
