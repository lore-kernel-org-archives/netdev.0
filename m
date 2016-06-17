From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v4 3/4] net: core: add SW stats to if_stats_msg
Date: Fri, 17 Jun 2016 09:32:49 +0200
Message-ID: <20160617073249.GC2001@nanopsycho.orion>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
 <1466066237-7719-4-git-send-email-jiri@resnulli.us>
 <20160616.172048.1390765203474702977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35776 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754191AbcFQHcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 03:32:52 -0400
Received: by mail-wm0-f66.google.com with SMTP id k184so16497045wme.2
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 00:32:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160616.172048.1390765203474702977.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jun 17, 2016 at 02:20:48AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Thu, 16 Jun 2016 10:37:16 +0200
>
>> @@ -1068,6 +1068,11 @@ static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
>>  	return 0;
>>  }
>>  
>> +static void copy_rtnl_link_stats64(void *v, const struct rtnl_link_stats64 *b)
>> +{
>> +	memcpy(v, b, sizeof(*b));
>> +}
> ...
>> +	struct rtnl_link_stats64 *stats64_sp = NULL;
>> +	struct rtnl_link_stats64 *sp;
> ...
>> +				copy_rtnl_link_stats64(sp, stats64_sp);
>
>I don't see any reason why copy_rtnl_link_stats64's first argument should be
>"void *".  Please make it "struct rtnl_link_stats64 *".
>
>In fact just doing a straight memcpy() inline is probably the best, there are
>no special typing nor casting requirements here.

Will do. Thanks.
