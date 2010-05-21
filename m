From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Fri, 21 May 2010 12:40:54 -0400
Message-ID: <20100521164054.GB29521@hmsreliant.think-freely.org>
References: <20100520172918.GA17613@shamino.rdu.redhat.com>
 <20100520231630.GA22593@gondor.apana.org.au>
 <20100521003939.GA2223@localhost.localdomain>
 <20100520.224944.102694876.davem@davemloft.net>
 <20100521105128.GA29521@hmsreliant.think-freely.org>
 <20100521110847.GA29878@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	bmb@athenacr.com, tgraf@redhat.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37159 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934020Ab0EUQlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 12:41:06 -0400
Content-Disposition: inline
In-Reply-To: <20100521110847.GA29878@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 21, 2010 at 09:08:47PM +1000, Herbert Xu wrote:
> On Fri, May 21, 2010 at 06:51:28AM -0400, Neil Horman wrote:
> >
> > I read it, we just described the issue in diferent terms.
> 
> Yeah I wasn't clear enough with my email without an actual patch :)
> 
> Thanks for testing Neil!

So a bit of bad news.  I think you're patch is correct herbert but its still not
working.  When I initially started messing with this it was on 2.6.32.  But
since you're patches I (naturally) started testing them on 2.6.34.  Whereas in
2.6.32 the tasks classid value for the net_cls cgroup subsys was set properly,
in 2.6.34 its not.  It appears since we started using the cgroup subsys
registration calls, we never registered an attach method, so we never set the
tasks classid, so the comparison always fails.

There may also be an issue with the setting of the classid (possible use of the
wrong subsys id value when grabbing our cgroup_subsys_state), but I'm checking
on that now.


Best
Neil

> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 
