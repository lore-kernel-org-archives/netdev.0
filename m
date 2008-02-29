From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [ATM]: Add error handling for proc_create fail
Date: Fri, 29 Feb 2008 10:38:03 -0800 (PST)
Message-ID: <20080229.103803.151963676.davem@davemloft.net>
References: <47C7B79C.2010304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42582
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752556AbYB2SiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 13:38:04 -0500
In-Reply-To: <47C7B79C.2010304@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 29 Feb 2008 15:43:24 +0800

> @@ -963,6 +963,10 @@ static int __init atm_clip_init(void)
>  		struct proc_dir_entry *p;
>  
>  		p = proc_create("arp", S_IRUGO, atm_proc_root, &arp_seq_fops);
> +		if (!p) {
> +			printk(KERN_ERR "Unable to initialize /proc/atm/arp\n");
> +			return -ENOMEM;
> +		}
>  	}
>  #endif
>  

This is not sufficient.  If this fails you need to unregister
the ioctl and all of the other things that get registered
before this procfs registry runs.
