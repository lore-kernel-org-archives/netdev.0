From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] af-packet: Save reference to bound network device.
Date: Wed, 25 May 2011 18:14:18 -0400 (EDT)
Message-ID: <20110525.181418.1100603684033986711.davem@davemloft.net>
References: <1306360602-9672-1-git-send-email-greearb@candelatech.com>
	<20110525.180113.1194226831134092545.davem@davemloft.net>
	<4DDD7D16.6030907@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756636Ab1EYWOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 18:14:21 -0400
In-Reply-To: <4DDD7D16.6030907@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Wed, 25 May 2011 15:05:10 -0700

> Doesn't this piece of code take care of that?
> I tested with rmmod..but of course I could have missed something.
> 
> @@ -2266,6 +2284,10 @@ static int packet_notifier(struct
> notifier_block *this, unsigned long msg, void
>  				}
>  				if (msg == NETDEV_UNREGISTER) {
>  					po->ifindex = -1;
> +					if (po->bound_dev) {
> + dev_put(po->bound_dev);
> +						po->bound_dev = NULL;
> +					}
>  					po->prot_hook.dev = NULL;
>  				}
>  				spin_unlock(&po->bind_lock);
> 

Indeed, it should, thanks for pointing that out.

Wait a second, why do you need to store the device a second
time, can't you get at po->prot_hook.dev in all the necessary
spots?
