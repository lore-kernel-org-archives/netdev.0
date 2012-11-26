From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next PATCH V1 0/9] net: fragmentation performance
 scalability on NUMA/SMP systems
Date: Mon, 26 Nov 2012 07:15:50 -0800
Message-ID: <1353942950.30446.1772.camel@edumazet-glaptop>
References: <20121123130749.18764.25962.stgit@dragon>
	 <1353810665.2590.4774.camel@edumazet-glaptop>
	 <1353833627.11754.134.camel@localhost>
	 <1353859891.30446.634.camel@edumazet-glaptop>
	 <1353940930.11754.221.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:50188 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754398Ab2KZPPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 10:15:53 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so6451777iea.19
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 07:15:53 -0800 (PST)
In-Reply-To: <1353940930.11754.221.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-26 at 15:42 +0100, Jesper Dangaard Brouer wrote:
> On Sun, 2012-11-25 at 08:11 -0800, Eric Dumazet wrote:
> > On Sun, 2012-11-25 at 09:53 +0100, Jesper Dangaard Brouer wrote:
> > 
> > > Yes, for the default large 64k packets size, its just a "fake"
> > > benchmark.  And notice with my fixes, we are even faster than the
> > > none-frag/single-UDP packet case... but its because we are getting a
> > > GSO/GRO effect.
> > 
> > Could you elaborate on this GSO/GRO effect ?
> 
> On the big system, I saw none-frag UDP (1472 bytes) throughput of:
>   7356.57 + 7351.78 + 7330.60 + 7269.26 = 29308.21 Mbit/s
> 
> While with UDP fragments size 65507 bytes I saw:
>   9228.75 + 9207.81 + 9615.83 + 9615.87 = 37668.26 Mbit/s
> 
> Fragmented UDP is faster by:
>  37668.26 - 29308.21 = 8360.05 Mbit/s
> 
> The 65507 bytes UDP size is just a benchmark test, and have no real-life
> relevance.  As performance starts to drop (below none-frag/normal case)
> when the frag size is decreased, to more realistic sizes...

Yes, but I doubt GRO / GSO are the reason you get better performance.

GRO doesnt aggregate UDP frames.
