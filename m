From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] RTEXT_FILTER_SKIP_STATS support to avoid dumping
 inet/inet6 stats
Date: Thu, 10 Sep 2015 13:29:33 -0700 (PDT)
Message-ID: <20150910.132933.1956643418409700904.davem@davemloft.net>
References: <20150910201649.GD28585@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghavendra.kt@linux.vnet.ibm.com,
	roopa@cumulusnetworks.com, eric.dumazet@gmail.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbbIJU3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 16:29:36 -0400
In-Reply-To: <20150910201649.GD28585@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 10 Sep 2015 16:16:49 -0400

> @@ -1272,7 +1273,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  			if (!(af = nla_nest_start(skb, af_ops->family)))
>  				goto nla_put_failure;
>  
> -			err = af_ops->fill_link_af(skb, dev);
> +			err = af_ops->fill_link_af(skb, dev, skip_af_stats);

Maybe just pass down the raw flags as 'ext_filter_mask', like we do
for the rtnl_fill_ifinfo() call chain.
