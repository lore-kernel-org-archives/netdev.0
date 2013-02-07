From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netpoll: cleanup sparse warnings
Date: Thu, 07 Feb 2013 07:52:56 -0800
Message-ID: <1360252376.28557.52.camel@edumazet-glaptop>
References: <1360248961-30721-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
	David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:63833 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758292Ab3BGPxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 10:53:00 -0500
Received: by mail-pa0-f53.google.com with SMTP id bg4so1464164pad.12
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 07:53:00 -0800 (PST)
In-Reply-To: <1360248961-30721-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-07 at 09:56 -0500, Neil Horman wrote:
> With my recent commit I introduced two sparse warnings.  Looking closer there
> were a few more in the same file, so I fixed them all up.  Basic rcu pointer
> dereferencing suff

> -	npinfo = np->dev->npinfo;
> +	/* rtnl_dereference would be preferable here but
> +	 * rcu_cleanup_netpoll path can put us in here safely without
> +	 * holding the rtnl, so plain rcu_dereference it is
> +	 */
> +	npinfo = rcu_dereference(np->dev->npinfo);
>  	if (!npinfo)
>  		return;
>  

Are you sure it wont trigger a LOCKDEP complain (CONFIG_PROVE_RCU=y) ?
