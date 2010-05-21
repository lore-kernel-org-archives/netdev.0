From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Fri, 21 May 2010 11:02:11 +1000
Message-ID: <20100521010211.GA23671@gondor.apana.org.au>
References: <20100520025741.GA6129@gondor.apana.org.au> <20100519.200522.140743640.davem@davemloft.net> <20100520033446.GA6434@gondor.apana.org.au> <1274332507.2658.31.camel@edumazet-laptop> <20100520052059.GC7443@gondor.apana.org.au> <1274333779.2658.43.camel@edumazet-laptop> <20100520054642.GA7836@gondor.apana.org.au> <20100520172918.GA17613@shamino.rdu.redhat.com> <20100520231630.GA22593@gondor.apana.org.au> <20100521003939.GA2223@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@redhat.com, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:32921 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751586Ab0EUBC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 21:02:27 -0400
Content-Disposition: inline
In-Reply-To: <20100521003939.GA2223@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 20, 2010 at 08:39:39PM -0400, Neil Horman wrote:
>
> > Not very surprising since tun.c doesn't go through the normal
> > socket interface.  I'll send a additional patch for that.
> > 
> I don't think thats it.  I think its a chicken and egg situation.  I think the
> problem is that tasks can't be assigned to cgroups until their created, and in
> that time a sock can be created.  Its a natural race.  If you create a socket
> before you assign it to a cgroup, that socket retains a classid of zero.  I'm
> going to try modify the patch to update sockets owned by tasks when the cgroup
> is assigned.

That's what I meant above.  My patch will make tun.c to the
classid update every time it sends out a packet.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
