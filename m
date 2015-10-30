From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net 1/2] ipv4: fix to not remove local route on link
 down
Date: Fri, 30 Oct 2015 12:18:12 +0900 (KST)
Message-ID: <20151030.121812.1043202779633665864.davem@davemloft.net>
References: <1445896753-14464-1-git-send-email-ja@ssi.bg>
	<1445896753-14464-2-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@cumulusnetworks.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756561AbbJ3DSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 23:18:15 -0400
In-Reply-To: <1445896753-14464-2-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Mon, 26 Oct 2015 23:59:12 +0200

 ...
> -int fib_sync_down_dev(struct net_device *dev, unsigned long event)
> +/* Event              force Flags           Description
> + * NETDEV_CHANGE      0     LINKDOWN        Carrier OFF, not for scope host
> + * NETDEV_DOWN        0     LINKDOWN|DEAD   Link down, not for scope host
> + * NETDEV_DOWN        1     LINKDOWN|DEAD   Last address removed
> + * NETDEV_UNREGISTER  2     LINKDOWN|DEAD   Device removed
> + */
> +int fib_sync_down_dev(struct net_device *dev, unsigned long event, int force)
>  {
>  	int ret = 0;
>  	int scope = RT_SCOPE_NOWHERE;
> @@ -1290,8 +1296,7 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event)
>  	struct hlist_head *head = &fib_info_devhash[hash];
>  	struct fib_nh *nh;
>  
> -	if (event == NETDEV_UNREGISTER ||
> -	    event == NETDEV_DOWN)
> +	if (force)
>  		scope = -1;

Julian the force variable is only used in a boolean manner, and in
fact 'event' + a boolean is enough to distinguish all of the necessary
cases so really using a non-bool for 'force' does not convey any extra
information.

So please use 'bool' and 'true/false' for 'force'.

Thanks.
