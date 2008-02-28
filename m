From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/15] [SUNRPC]: Use proc_create() to setup ->proc_fops
 first
Date: Thu, 28 Feb 2008 14:02:22 -0800 (PST)
Message-ID: <20080228.140222.07061140.davem@davemloft.net>
References: <47C6932C.90907@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51585
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753888AbYB1WCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 17:02:23 -0500
In-Reply-To: <47C6932C.90907@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 28 Feb 2008 18:55:40 +0800

> Use proc_create() to make sure that ->proc_fops be setup before gluing
> PDE to main tree.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.

> @@ -229,9 +229,8 @@ do_register(const char *name, void *data, const struct file_operations *fops)
>  	rpc_proc_init();
>  	dprintk("RPC:       registering /proc/net/rpc/%s\n", name);
>  
> -	ent = create_proc_entry(name, 0, proc_net_rpc);
> +	ent = proc_create(name, 0, proc_net_rpc, fops);
>  	if (ent) {
> -		ent->proc_fops = fops;
>  		ent->data = data;
>  	}
>  	return ent;

For this case it appears that ent->data has the same kind of
visibility problem that ent->proc_fops does.
