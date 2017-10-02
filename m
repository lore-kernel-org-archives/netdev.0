From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: core: decouple ifalias get/set from rtnl
 lock
Date: Sun, 01 Oct 2017 22:46:44 -0700 (PDT)
Message-ID: <20171001.224644.903150013683866978.davem@davemloft.net>
References: <20170929112150.7424-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60602 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750752AbdJBFqp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 01:46:45 -0400
In-Reply-To: <20170929112150.7424-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 29 Sep 2017 13:21:50 +0200

> @@ -1488,7 +1484,7 @@ static void netdev_release(struct device *d)
>  
>  	BUG_ON(dev->reg_state != NETREG_RELEASED);
>  
> -	kfree(dev->ifalias);
> +	kfree(rcu_access_pointer(dev->ifalias));
>  	netdev_freemem(dev);
>  }
>  

"kfree_rcu()" at least?

If the deal is that you don't need to do and RCU free because
netdevice objects disappear synchronously, and you can therefore prove
that no RCU based async access can occur to dev->ifalias, then you
need to add a comment here.
