From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: report congestion
 notification at enqueue time
Date: Thu, 28 Jun 2012 20:12:31 +0200
Message-ID: <1340907151.13187.169.camel@edumazet-glaptop>
References: <1340903237.13187.151.camel@edumazet-glaptop>
	<CAA93jw7agn2J6Hd7x22KWhENY5jqVjnk6uRr=3LJ5Anw7EgacQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nandita Dukkipati <nanditad@google.com>, netdev <netdev@vger.kernel.org>,
	codel@lists.bufferbloat.net, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>, David Miller <davem@davemloft.net>,
	Matt Mathis <mattmathis@google.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CAA93jw7agn2J6Hd7x22KWhENY5jqVjnk6uRr=3LJ5Anw7EgacQ@mail.gmail.com>
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

On Thu, 2012-06-28 at 10:51 -0700, Dave Taht wrote:

> clever idea. A problem is there are other forms of network traffic on
> a link, and this is punishing a single tcp
> stream that may not be the source of the problem in the first place,
> and basically putting it into double jeopardy.
> 

Why ? In fact this patch helps the tcp session being signaled (as it
will be anyway) at enqueue time, instead of having to react to packet
losses indications given (after RTT) by receiver.

Avoiding losses help receiver to consume data without having to buffer
it into Out Of Order queue.

So its not jeopardy, but early congestion notification without RTT
delay.

NET_XMIT_CN is a soft signal, far more disruptive than a DROP.

> I am curious as to how often an enqueue is actually dropping in the
> codel/fq_codel case, the hope was that there would be plenty of
> headroom under far more circumstances on this qdisc.
> 

"tc -s qdisc show dev eth0" can show you all the counts.

We never drop a packet at enqueue time, unless you hit the emergency
limit (10240 packets for fq_codel). When you reach this limit, you are
under trouble.
