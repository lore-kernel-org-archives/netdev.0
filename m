From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC net-next PATCH V1 0/9] net: fragmentation performance
 scalability on NUMA/SMP systems
Date: Mon, 26 Nov 2012 15:42:10 +0100
Message-ID: <1353940930.11754.221.camel@localhost>
References: <20121123130749.18764.25962.stgit@dragon>
	 <1353810665.2590.4774.camel@edumazet-glaptop>
	 <1353833627.11754.134.camel@localhost>
	 <1353859891.30446.634.camel@edumazet-glaptop>
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
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57232 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754299Ab2KZOpP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2012 09:45:15 -0500
In-Reply-To: <1353859891.30446.634.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-11-25 at 08:11 -0800, Eric Dumazet wrote:
> On Sun, 2012-11-25 at 09:53 +0100, Jesper Dangaard Brouer wrote:
> 
> > Yes, for the default large 64k packets size, its just a "fake"
> > benchmark.  And notice with my fixes, we are even faster than the
> > none-frag/single-UDP packet case... but its because we are getting a
> > GSO/GRO effect.
> 
> Could you elaborate on this GSO/GRO effect ?

On the big system, I saw none-frag UDP (1472 bytes) throughput of:
  7356.57 + 7351.78 + 7330.60 + 7269.26 = 29308.21 Mbit/s

While with UDP fragments size 65507 bytes I saw:
  9228.75 + 9207.81 + 9615.83 + 9615.87 = 37668.26 Mbit/s

Fragmented UDP is faster by:
 37668.26 - 29308.21 = 8360.05 Mbit/s

The 65507 bytes UDP size is just a benchmark test, and have no real-life
relevance.  As performance starts to drop (below none-frag/normal case)
when the frag size is decreased, to more realistic sizes...


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
