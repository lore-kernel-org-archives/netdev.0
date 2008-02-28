From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/15] [IRDA]: Use proc_create() to setup ->proc_fops
 first
Date: Thu, 28 Feb 2008 14:08:21 -0800 (PST)
Message-ID: <20080228.140821.249369808.davem@davemloft.net>
References: <47C69367.6000609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38410
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757478AbYB1WIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 17:08:21 -0500
In-Reply-To: <47C69367.6000609@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 28 Feb 2008 18:56:39 +0800

> @@ -75,11 +75,8 @@ static int __init ircomm_init(void)
>  	}
>  
>  #ifdef CONFIG_PROC_FS
> -	{ struct proc_dir_entry *ent;
> -	ent = create_proc_entry("ircomm", 0, proc_irda);
> -	if (ent)
> -		ent->proc_fops = &ircomm_proc_fops;
> -	}
> +	struct proc_dir_entry *ent;
> +	ent = proc_create("ircomm", 0, proc_irda, &ircomm_proc_fops);
>  #endif /* CONFIG_PROC_FS */
>  
>  	IRDA_MESSAGE("IrCOMM protocol (Dag Brattli)\n");

This is not C++, you therefore cannot declare local variables in
arbitrary locations of the function body.  That's what the braces
were there for, to create the necessary new local scope.

For certain versions of GCC this won't even build, newer versions
default to c99 or similar and therefore just so happen to work.
