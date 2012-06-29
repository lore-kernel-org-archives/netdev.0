From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fq_codel: report congestion
 notification at enqueue time
Date: Thu, 28 Jun 2012 22:29:34 -0700 (PDT)
Message-ID: <20120628.222934.767995619021650710.davem@davemloft.net>
References: <1340945592.29822.8.camel@edumazet-glaptop>
	<20120628.221252.2220466000873887315.davem@davemloft.net>
	<1340947448.29822.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, codel@lists.bufferbloat.net,
	ycheng@google.com, ncardwell@google.com, mattmathis@google.com
To: eric.dumazet@gmail.com
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1340947448.29822.41.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Jun 2012 07:24:08 +0200

> By the way, I am not sure NET_XMIT_CN is correctly used in RED.
> 
> Or maybe my understanding of NET_XMIT_CN is wrong.
> 
> If a the packet is dropped in enqueue(), why use NET_XMIT_CN instead of 
> NET_XMIT_DROP ?
> 
> This seems to mean : I dropped _this_ packet, but dont worry too much, I
> might accept other packets, so please go on...

I am pretty sure the behavior in RED is intentional.

It's a soft push back on TCP.

We're taking this path when we are unable to sucessfully ECN mark a
packet.  But our intention was to do so.
