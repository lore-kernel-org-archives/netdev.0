From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH v1 2/3] net: add VEPA, VEB bridge mode
Date: Mon, 4 Jun 2012 20:29:57 +0530
Message-ID: <OF0D72A103.6F322B98-ON65257A13.00500E50-65257A13.005272D6@in.ibm.com>
References: <20120530030531.7443.72024.stgit@jf-dev1-dcblab> <20120530030705.7443.22155.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bhutchings@solarflare.com, buytenh@wantstofly.org,
	eilong@broadcom.com, eric.w.multanen@intel.com,
	gregory.v.rose@intel.com, hadi@cyberus.ca,
	jeffrey.t.kirsher@intel.com, mst@redhat.com,
	netdev@vger.kernel.org, shemminger@vyatta.com, sri@us.ibm.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:44835 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755597Ab2FDPAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:00:45 -0400
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Mon, 4 Jun 2012 20:30:42 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q54F0bu361604048
	for <netdev@vger.kernel.org>; Mon, 4 Jun 2012 20:30:37 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q54KUM88027054
	for <netdev@vger.kernel.org>; Tue, 5 Jun 2012 06:30:24 +1000
In-Reply-To: <20120530030705.7443.22155.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Fastabend <john.r.fastabend@intel.com> wrote on 05/30/2012 08:37:06
AM:

Some comments below:

> +static int rtnl_bridge_notify(struct net_device *dev, u16 flags)
> +{
> ...
> +		 if (!flags && master && master->netdev_ops->
ndo_bridge_getlink)
> +		 		 err = master->netdev_ops->ndo_bridge_getlink(skb,
0, 0, dev);
> +		 else if (dev->netdev_ops->ndo_bridge_getlink)
> +		 		 err = dev->netdev_ops->ndo_bridge_getlink(skb, 0,
0, dev);

I think you should do something like:

        if ((flags == BRIDGE_FLAGS_MASTER) && ...)
                ...

Also you could use BRIDGE_FLAGS_MASTER=1, SELF=2, and use
"if (flags & BRIDGE_FLAGS_MASTER)" for consistency?


+		 if (!err)
+		 		 err = rtnl_bridge_notify(dev, flags);

It is possible to return a reporting error even though
the operation succeeded. Maybe something that could be
done here to indicate that the operation succeeded, or
is that a TODO?

>  static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr
*nlh,
>                  void *arg)
>  {
..
> +   if (!flags && dev->master &&
> +       dev->master->netdev_ops->ndo_bridge_setlink)
> +      err = dev->master->netdev_ops->ndo_bridge_setlink(dev, nlh);
> +   else if ((flags & BRIDGE_FLAGS_SELF) &&
> +         dev->netdev_ops->ndo_bridge_setlink)

Same usage of MASTER here.

Thanks,
- KK
