From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel problem
Date: Fri, 27 Feb 2009 09:12:16 +0000
Message-ID: <20090227091216.GB4156@ff.dom.local>
References: <20090226130631.GA14125@gondor.apana.org.au> <20090227041136.GA21468@gondor.apana.org.au> <20090227084109.GA4156@ff.dom.local> <20090227.005907.94994126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, ash@sevsky.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:54319 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387AbZB0JMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 04:12:23 -0500
Received: by fxm24 with SMTP id 24so938688fxm.37
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 01:12:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090227.005907.94994126.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 12:59:07AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 27 Feb 2009 08:41:10 +0000
> 
> > Probably I miss something, but I'm not sure it's really necessary in
> > all (non-VLAN) entry points. Of course it's an optimization to drop
> > these things early, but there is a lot off mess with replicating
> > various parts of netif_receive_skb() in so many places.
> > 
> > As a matter of fact, I wonder why it can't be done in one place, e.g.
> > netif_nit_deliver(), which was created partly for similar problems.
> 
> I think we do need to hit all possible entry points.
> 
> How would you be able to handle it in netif_nit_deliver()?
> Functions like netif_receive_skb() open-code the delivery to
> network taps, they don't actually call netif_receive_skb().

netif_nit_deliver() is a place called by vlan with orig skb->dev, so
it could be reused to check for netpoll btw. Of course, return value
should be added etc. and maybe name changed too. It could be
something like this:

netif_receive_skb()

	if (skb->vlan_tci) {
		ret = vlan_hwaccel_do_receive(skb);
		if (ret)
			return ret;
	}
...

Jarek P.
