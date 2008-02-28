From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/15] [WANROUTER]: Use proc_create() to setup
 ->proc_fops first
Date: Thu, 28 Feb 2008 14:16:11 -0800 (PST)
Message-ID: <20080228.141611.43422202.davem@davemloft.net>
References: <47C693DB.7040002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56880
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758644AbYB1WQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 17:16:12 -0500
In-Reply-To: <47C693DB.7040002@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 28 Feb 2008 18:58:35 +0800

> Use proc_create() to make sure that ->proc_fops be setup before gluing
> PDE to main tree.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.

> @@ -329,10 +327,10 @@ int wanrouter_proc_add(struct wan_device* wandev)
>  	if (wandev->magic != ROUTER_MAGIC)
>  		return -EINVAL;
>  
> -	wandev->dent = create_proc_entry(wandev->name, S_IRUGO, proc_router);
> +	wandev->dent = proc_create(wandev->name, S_IRUGO,
> +				   proc_router, &wandev_fops);
>  	if (!wandev->dent)
>  		return -ENOMEM;
> -	wandev->dent->proc_fops	= &wandev_fops;
>  	wandev->dent->data	= wandev;
>  	return 0;
>  }

->data visibility issue
