From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/15] [IPV6]: Use proc_create() to setup ->proc_fops
 first
Date: Thu, 28 Feb 2008 14:14:01 -0800 (PST)
Message-ID: <20080228.141401.147530141.davem@davemloft.net>
References: <47C693AD.5050705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56871
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759147AbYB1WOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 17:14:02 -0500
In-Reply-To: <47C693AD.5050705@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 28 Feb 2008 18:57:49 +0800

> Use proc_create() to make sure that ->proc_fops be setup before gluing
> PDE to main tree.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.

> @@ -217,12 +217,12 @@ int snmp6_register_dev(struct inet6_dev *idev)
>  	if (!proc_net_devsnmp6)
>  		return -ENOENT;
>  
> -	p = create_proc_entry(idev->dev->name, S_IRUGO, proc_net_devsnmp6);
> +	p = proc_create(idev->dev->name, S_IRUGO,
> +			proc_net_devsnmp6, &snmp6_seq_fops);
>  	if (!p)
>  		return -ENOMEM;
>  
>  	p->data = idev;
> -	p->proc_fops = &snmp6_seq_fops;
>  
>  	idev->stats.proc_dir_entry = p;
>  	return 0;

->data visibility issue
