From: steve@chygwyn.com
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening
	sockets, and for IPv4 multicast forwarding
Date: Wed, 14 Oct 2009 11:16:49 +0100
Message-ID: <20091014101649.GA13944@fogou.chygwyn.com>
References: <20091007.223928.34412707.davem@davemloft.net> <55a4f86e0910140250o45532dabr33707c025dfa25f9@mail.gmail.com> <20091014092743.GA13374@fogou.chygwyn.com> <200910141404.37882.atis@mikrotik.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	panther@balabit.hu, eric.dumazet@gmail.com, brian.haley@hp.com
To: Atis Elsts <atis@mikrotik.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:42356 "EHLO fogou.chygwyn.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757163AbZJNLXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 07:23:30 -0400
Content-Disposition: inline
In-Reply-To: <200910141404.37882.atis@mikrotik.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Oct 14, 2009 at 02:04:37PM +0300, Atis Elsts wrote:
> On Wednesday 14 October 2009 12:27:43 steve@chygwyn.com wrote:
> >
> > The mark is supposed to be a generic thing, not just for routing
> > lookups, it can be used for classification, etc as well. 
> 
> In general, sounds like a good idea, but IMHO exactly this could be a problem.
> skb->mark is already used for a lot of things. What if I am setting the mark 
> by a firewall rule in prerouting chain, and matching it by a postrouting 
> rule? If routing lookup was changing the mark, then my setup would break.
>
Yes, thats exactly why I said that it should default to the current
behaviour.
 
> Perhaps one more field could be added dst_entry? The field would be filled 
> from route's table (if "setmark" for that route was specified). The use of 
> that field would be similar to tclassid (e.g matching in firewall), except 
> that it would also be used in routing lookups, if set.
>
Yes, I think that we are both thinking along the same lines. There
must obviously be a default "don't touch" setting,

Steve.
