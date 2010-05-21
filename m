From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 20 May 2010 20:39:39 -0400
Message-ID: <20100521003939.GA2223@localhost.localdomain>
References: <20100519.195533.22536631.davem@davemloft.net>
 <20100520025741.GA6129@gondor.apana.org.au>
 <20100519.200522.140743640.davem@davemloft.net>
 <20100520033446.GA6434@gondor.apana.org.au>
 <1274332507.2658.31.camel@edumazet-laptop>
 <20100520052059.GC7443@gondor.apana.org.au>
 <1274333779.2658.43.camel@edumazet-laptop>
 <20100520054642.GA7836@gondor.apana.org.au>
 <20100520172918.GA17613@shamino.rdu.redhat.com>
 <20100520231630.GA22593@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@redhat.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47728 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756371Ab0EUAjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 20:39:51 -0400
Content-Disposition: inline
In-Reply-To: <20100520231630.GA22593@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 21, 2010 at 09:16:30AM +1000, Herbert Xu wrote:
> On Thu, May 20, 2010 at 01:29:18PM -0400, Neil Horman wrote:
> >
> > So, I'm testing this patch out now, and unfotunately it doesn't seem to be
> > working.  Every frame seems to be holding a classid of 0.  Trying to figure out
> > why now.
> 
> Not very surprising since tun.c doesn't go through the normal
> socket interface.  I'll send a additional patch for that.
> 
I don't think thats it.  I think its a chicken and egg situation.  I think the
problem is that tasks can't be assigned to cgroups until their created, and in
that time a sock can be created.  Its a natural race.  If you create a socket
before you assign it to a cgroup, that socket retains a classid of zero.  I'm
going to try modify the patch to update sockets owned by tasks when the cgroup
is assigned.

Best
Neil

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 
