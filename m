From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 5/6] net: dsa: Initialize CPU port ethtool
 ops per tree
Date: Wed, 8 Jun 2016 00:24:12 +0200
Message-ID: <20160607222412.GG28994@lunn.ch>
References: <1465333616-6351-1-git-send-email-f.fainelli@gmail.com>
 <1465333616-6351-6-git-send-email-f.fainelli@gmail.com>
 <20160607215120.GF28994@lunn.ch>
 <5757470F.7090304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38339 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932782AbcFGWYO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 18:24:14 -0400
Content-Disposition: inline
In-Reply-To: <5757470F.7090304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 03:13:35PM -0700, Florian Fainelli wrote:
> On 06/07/2016 02:51 PM, Andrew Lunn wrote:
> >> +int dsa_cpu_port_ethtool_setup(struct dsa_switch_tree *dst,
> >> +			       struct dsa_switch *ds)
> >> +{
> >> +	struct net_device *master;
> >> +	struct ethtool_ops *cpu_ops;
> >> +
> >> +	master = ds->dst->master_netdev;
> > 
> > You pass in dst as a parameter, and then don't use it!
> 
> I do use it here:
> 
>         memcpy(&dst->master_ethtool_ops, master->ethtool_ops,
>                sizeof(struct ethtool_ops));

Yes, i noticed this. I also expect the compiler has also noticed, and
has optimized away one of the parameters.
 
> I sure could simplify that and use ds->dst instead if you find it more
> elegant, works for me.

I would prefer the code to be consistent. Either use ds->dst
everywhere and drop the parameter, or use the parameter everywhere it
is usable.

   Thanks
	Andrew
