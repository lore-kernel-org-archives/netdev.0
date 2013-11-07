From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Fri, 8 Nov 2013 05:31:11 +0800
Message-ID: <20131107213111.GA6885@gondor.apana.org.au>
References: <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
 <1383422330.4291.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
 <20131107.161755.355597965034457889.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, eric.dumazet@gmail.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:58744 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752009Ab3KGVbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 16:31:17 -0500
Content-Disposition: inline
In-Reply-To: <20131107.161755.355597965034457889.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 04:17:55PM -0500, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 4 Nov 2013 16:55:30 +0000
> 
> > On Sat, 2013-11-02 at 12:58 -0700, Eric Dumazet wrote:
> >> From: Eric Dumazet <edumazet@google.com>
> >> 
> >> Christoph Paasch and Jerry Chu reported crashes in skb_segment() caused
> >> by commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> >> 
> >> skb_segment() only deals with a frag_list chain containing MSS sized
> >> fragments. Even if we fix this problem, its better if GRO layer
> >> doesn't build skb with a frag_list in the first place, to let TSO
> >> packets reaching output devices.
> >>  
> >> David Miller and Ben Hutchings suggested we keep track of number of
> >> forwarding users to be able to :
> >> 
> >> - Disable LRO
> >> - Make sure GRO layer do not use skb frag_list to extend skb capacity
> >> 
> >> Note that after this patch, LRO is automatically re-enabled if
> >> forwarding is disabled on the device, or if a device is removed
> >> from a bridge.
> > [...]
> > 
> > Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Applied, thanks everyone.

Sorry David, I just realised that this patch doesn't address
this problem fully.  While we can stop the generation of these
packets in our own stack, if they're coming from the virt host
or another guest, there is nothing we can do to stop them.

So given virtio_net is now generating such packets, our choices
are either to linearise them or deal with them properly in skb_segment.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
