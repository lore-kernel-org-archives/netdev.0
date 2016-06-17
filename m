From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v4 3/4] net: core: add SW stats to if_stats_msg
Date: Thu, 16 Jun 2016 17:20:48 -0700 (PDT)
Message-ID: <20160616.172048.1390765203474702977.davem@davemloft.net>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
	<1466066237-7719-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44531 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753818AbcFQAUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 20:20:50 -0400
In-Reply-To: <1466066237-7719-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 16 Jun 2016 10:37:16 +0200

> @@ -1068,6 +1068,11 @@ static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
>  	return 0;
>  }
>  
> +static void copy_rtnl_link_stats64(void *v, const struct rtnl_link_stats64 *b)
> +{
> +	memcpy(v, b, sizeof(*b));
> +}
 ...
> +	struct rtnl_link_stats64 *stats64_sp = NULL;
> +	struct rtnl_link_stats64 *sp;
 ...
> +				copy_rtnl_link_stats64(sp, stats64_sp);

I don't see any reason why copy_rtnl_link_stats64's first argument should be
"void *".  Please make it "struct rtnl_link_stats64 *".

In fact just doing a straight memcpy() inline is probably the best, there are
no special typing nor casting requirements here.

Thanks.
