From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/6] ipv4: fix sending of redirects
Date: Mon, 08 Oct 2012 15:16:33 -0400 (EDT)
Message-ID: <20121008.151633.753185005887436197.davem@davemloft.net>
References: <1349609168-9848-1-git-send-email-ja@ssi.bg>
	<1349609168-9848-2-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57102 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753498Ab2JHTQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 15:16:35 -0400
In-Reply-To: <1349609168-9848-2-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun,  7 Oct 2012 14:26:03 +0300

> @@ -322,7 +322,8 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
>  {
>  	int r = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
>  
> -	if (!r && !fib_num_tclassid_users(dev_net(dev))) {
> +	if (!r && !fib_num_tclassid_users(dev_net(dev)) &&
> +	    dev->ifindex != oif) {
>  		*itag = 0;
>  		return 0;
>  	}

Hmmm, won't this cause the slow path to be taken for locally
destined traffic?

> +			  rt->rt_gateway ? : ip_hdr(skb)->daddr);

Please use the rt_nexthop() helper.

> +		__be32 gw = rt->rt_gateway ? : ip_hdr(skb)->daddr;

Likewise.
