From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 5/6] net: dsa: Initialize CPU port ethtool ops
 per tree
Date: Tue, 7 Jun 2016 15:13:35 -0700
Message-ID: <5757470F.7090304@gmail.com>
References: <1465333616-6351-1-git-send-email-f.fainelli@gmail.com>
 <1465333616-6351-6-git-send-email-f.fainelli@gmail.com>
 <20160607215120.GF28994@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33674 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755488AbcFGWNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:13:38 -0400
Received: by mail-pa0-f66.google.com with SMTP id di3so15010187pab.0
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 15:13:38 -0700 (PDT)
In-Reply-To: <20160607215120.GF28994@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2016 02:51 PM, Andrew Lunn wrote:
>> +int dsa_cpu_port_ethtool_setup(struct dsa_switch_tree *dst,
>> +			       struct dsa_switch *ds)
>> +{
>> +	struct net_device *master;
>> +	struct ethtool_ops *cpu_ops;
>> +
>> +	master = ds->dst->master_netdev;
> 
> You pass in dst as a parameter, and then don't use it!

I do use it here:

        memcpy(&dst->master_ethtool_ops, master->ethtool_ops,
               sizeof(struct ethtool_ops));

> 
>> +void dsa_cpu_port_ethtool_restore(struct dsa_switch_tree *dst,
>> +				  struct dsa_switch *ds)
>> +{
>> +	struct net_device *master;
>> +
>> +	master = ds->dst->master_netdev;
> 
> Same here.

and here:

        master->ethtool_ops = dst->master_orig_ethtool_ops;

I sure could simplify that and use ds->dst instead if you find it more
elegant, works for me.
-- 
Florian
