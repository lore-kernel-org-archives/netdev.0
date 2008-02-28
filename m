From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/15] [PKTGEN]: Use proc_create() to setup ->proc_fops
 first
Date: Thu, 28 Feb 2008 14:12:42 -0800 (PST)
Message-ID: <20080228.141242.95871836.davem@davemloft.net>
References: <47C6938E.8010006@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56865
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760027AbYB1WMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 17:12:42 -0500
In-Reply-To: <47C6938E.8010006@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 28 Feb 2008 18:57:18 +0800

> Use proc_create() to make sure that ->proc_fops be setup before gluing
> PDE to main tree.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.

> @@ -3570,14 +3570,14 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
>  	if (err)
>  		goto out1;
>  
> -	pkt_dev->entry = create_proc_entry(ifname, 0600, pg_proc_dir);
> +	pkt_dev->entry = proc_create(ifname, 0600,
> +				     pg_proc_dir, &pktgen_if_fops);
>  	if (!pkt_dev->entry) {
>  		printk(KERN_ERR "pktgen: cannot create %s/%s procfs entry.\n",
>  		       PG_PROC_DIR, ifname);
>  		err = -EINVAL;
>  		goto out2;
>  	}
> -	pkt_dev->entry->proc_fops = &pktgen_if_fops;
>  	pkt_dev->entry->data = pkt_dev;
>  #ifdef CONFIG_XFRM
>  	pkt_dev->ipsmode = XFRM_MODE_TRANSPORT;

->data visibility issue

> @@ -3638,7 +3638,6 @@ static int __init pktgen_create_thread(int cpu)
>  		return -EINVAL;
>  	}
>  
> -	pe->proc_fops = &pktgen_thread_fops;
>  	pe->data = t;
>  
>  	wake_up_process(p);

Likewise.

> @@ -3717,7 +3716,6 @@ static int __init pg_init(void)
>  		return -EINVAL;
>  	}
>  
> -	pe->proc_fops = &pktgen_fops;
>  	pe->data = NULL;
>  
>  	/* Register us to receive netdevice events */

Superfluous assignment to NULL, can be deleted.
