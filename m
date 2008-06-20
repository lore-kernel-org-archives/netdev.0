From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/8] bridge: Check return of
 dev_set_promiscuity
Date: Thu, 19 Jun 2008 19:08:54 -0700 (PDT)
Message-ID: <20080619.190854.188264452.davem@davemloft.net>
References: <485AFFE4.4000300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, kaber@trash.net
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33151
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751049AbYFTCIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 22:08:55 -0400
In-Reply-To: <485AFFE4.4000300@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 20 Jun 2008 08:55:00 +0800

Sigh...

> @@ -389,7 +389,10 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>  		goto err2;
>  
>  	rcu_assign_pointer(dev->br_port, p);
> -	dev_set_promiscuity(dev, 1);
> +	/* If promiscuity overflow, return error */
> +	err = dev_set_promiscuity(dev, 1);
> +	if (err)
> +		goto err3;

Fixup this comment as I directed in my feedback for the previous patches.
These just look like turds all over the tree that you are adding for every
single dev_set_promiscuity() call site and it adds nothing to readability
or understandability of the code.

Anyways, Stephen also wanted you to implement this a different way.
