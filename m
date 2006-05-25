From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] bridge: fix locking and memory leak in br_add_bridge
Date: Thu, 25 May 2006 16:07:35 +0200
Message-ID: <20060525160735.3c2aa9a5@griffin.suse.cz>
References: <20060525153124.478bea57@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:36482 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1030195AbWEYOHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 10:07:38 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060525153124.478bea57@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 May 2006 15:31:24 +0200, Jiri Benc wrote:
>   err2:
> -	free_netdev(dev);
> +	unregister_netdevice(dev);
>   err1:
>  	rtnl_unlock();
> +	free_netdev(dev);
>  	return ret;

Sorry, this is wrong. I didn't notice that br_dev_setup sets
dev->destructor to free_netdev. Corrected patch will follow.

 Jiri

-- 
Jiri Benc
SUSE Labs
