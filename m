From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 1/2] inetpeer: add namespace support for
 inetpeer
Date: Tue, 5 Jun 2012 07:52:08 +0200
Message-ID: <20120605055208.GA27795@secunet.com>
References: <1338863012-4902-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1338867619.2760.1980.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gao feng <gaofeng@cn.fujitsu.com>, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46634 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932205Ab2FEFwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 01:52:11 -0400
Content-Disposition: inline
In-Reply-To: <1338867619.2760.1980.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 05, 2012 at 05:40:19AM +0200, Eric Dumazet wrote:
> On Tue, 2012-06-05 at 10:23 +0800, Gao feng wrote:
> >  
> > +static int __net_init inetpeer_net_init(struct net *net)
> > +{
> > +
> > +	net->ipv4.peers = kmemdup(&v4_peers,
> > +				  sizeof(v4_peers),
> > +				  GFP_KERNEL);
> 
> kzalloc(), and init ->root to peer_avl_empty_rcu
> 
> > +	if (net->ipv4.peers == NULL)
> > +		return -1;

...and return -ENOMEM if memory allocation fails.
