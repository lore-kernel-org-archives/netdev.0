From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH v2] bridge: fix locking and memory leak in br_add_bridge
Date: Fri, 26 May 2006 11:08:06 +0200
Message-ID: <20060526110806.1fa49fe1@griffin.suse.cz>
References: <20060525153124.478bea57@griffin.suse.cz>
	<20060525160735.3c2aa9a5@griffin.suse.cz>
	<20060525161432.4cbc11ee@griffin.suse.cz>
	<20060525092331.54f14a57@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:13704 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751348AbWEZJII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 05:08:08 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060525092331.54f14a57@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 May 2006 09:23:31 -0700, Stephen Hemminger wrote:
> +		unregister_netdevice(dev);
> + err:
>  	rtnl_unlock();
> +	if (ret)
> +		free_netdev(dev);
>  	return ret;

I don't think this is correct. netdev_run_todo calls dev->destructor
which is set to free_netdev by br_dev_setup. So you're calling
free_netdev on already freed device.

 Jiri

-- 
Jiri Benc
SUSE Labs
