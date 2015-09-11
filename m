From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH v3 net 1/5] ipv6: Refactor common ip6gre_tunnel_init codes
Date: Fri, 11 Sep 2015 16:20:26 -0700
Message-ID: <20150911231928.GA99086@kafai-mba.local>
References: <1441994781-2718585-1-git-send-email-kafai@fb.com>
 <1441994781-2718585-2-git-send-email-kafai@fb.com>
 <20150911.153059.459077104316140368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<hannes@stressinduktion.org>, <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56331 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752556AbbIKXUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 19:20:38 -0400
Content-Disposition: inline
In-Reply-To: <20150911.153059.459077104316140368.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2015 at 03:30:59PM -0700, David Miller wrote:
> From: Martin KaFai Lau <kafai@fb.com>
> Date: Fri, 11 Sep 2015 11:06:17 -0700
>
> > @@ -1460,19 +1474,16 @@ static void ip6gre_netlink_parms(struct nlattr *data[],
> >  static int ip6gre_tap_init(struct net_device *dev)
> >  {
> >  	struct ip6_tnl *tunnel;
> > +	int ret;
> >
> > -	tunnel = netdev_priv(dev);
> > +	ret = ip6gre_tunnel_init_common(dev);
> > +	if (ret)
> > +		return ret;
> >
> > -	tunnel->dev = dev;
> > -	tunnel->net = dev_net(dev);
> > -	strcpy(tunnel->parms.name, dev->name);
> > +	tunnel = netdev_priv(dev);
> >
> >  	ip6gre_tnl_link_config(tunnel, 1);
> >
> > -	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
> > -	if (!dev->tstats)
> > -		return -ENOMEM;
> > -
> >  	return 0;
> >  }
>
> Is this really equivalent?
>
> The existing code for GRE tap device initialization would use whatever
> ether_setup() left in the broadcast address, it would leave
> dev->dev_addr alone, and unconditionally use eth_header_ops.
The new ip6gre_tunnel_init_common() does not set the dev->dev_addr
or dev->header_ops.  The change in ip6gre_tap_init() is to initialize
dev->tstats before ip6gre_tnl_link_config().

or I am missing something and have overlooked a bug?

Thanks,
Martin
