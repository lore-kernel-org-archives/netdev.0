From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4] ipv6:introduce function to find route for redirect
Date: Tue, 3 Sep 2013 21:17:29 +0200
Message-ID: <20130903191729.GA28889@order.stressinduktion.org>
References: <52242CE1.5050501@cn.fujitsu.com> <20130902195056.GA5451@order.stressinduktion.org> <5225758F.8080604@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35330 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933202Ab3ICTRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 15:17:31 -0400
Content-Disposition: inline
In-Reply-To: <5225758F.8080604@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 03, 2013 at 01:37:19PM +0800, Duan Jiong wrote:
> > Btw. I still think it should be possible to eliminate
> > ip6_redirect_no_header:
> > 
> > We could always use ip6_redirect_no_header and use the data of the redirected
> > header option just for finding the socket to be notified. We can do the whole
> > verification and route updating in ndisc layer and then just call into icmpv6
> > layer if upper protocols need a notification of the redirect. But that should
> > go into another patch. ;)
> > 
> 
> I think this is good, but i have a question below:
> 
>   if the socket type is connection-based, the dst information is stored in related
> sock struct, so there is no need to look up the route for redirect in ip6_redirect
> or ip6_redirect_no_header, in this case, we do the verification and route 
> updating in the upper protocols' err_handler is better. 
> 
> How do you think of this?

This should not be a problem, because every cached dst should be validated
with ip6_dst_check before it is used. It uses the fib6_node serial number
which is incremented for all fib6_nodes on the path to the new installed
node by fib6_add_1. So we are safe here.

Btw. this is the same logic redirects get currently picked up, too.

Greetings,

  Hannes
