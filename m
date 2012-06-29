From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: report congestion
 notification at enqueue time
Date: Fri, 29 Jun 2012 06:50:57 +0200
Message-ID: <1340945457.29822.7.camel@edumazet-glaptop>
References: <1340903237.13187.151.camel@edumazet-glaptop>
	<CAA93jw7agn2J6Hd7x22KWhENY5jqVjnk6uRr=3LJ5Anw7EgacQ@mail.gmail.com>
	<1340907151.13187.169.camel@edumazet-glaptop>
	<CAK6E8=dM0HNjjT=pDWzkBHs2Npi9foAnk1zxXdVLqBxA63dSqw@mail.gmail.com>
	<CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nandita Dukkipati <nanditad@google.com>, netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>, codel@lists.bufferbloat.net,
	Matt Mathis <mattmathis@google.com>, Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
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

On Thu, 2012-06-28 at 19:47 -0400, Dave Taht wrote: 
> On Thu, Jun 28, 2012 at 6:56 PM, Yuchung Cheng <ycheng@google.com> wrote:
> > On Thu, Jun 28, 2012 at 11:12 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> On Thu, 2012-06-28 at 10:51 -0700, Dave Taht wrote:
> >>
> >>> clever idea. A problem is there are other forms of network traffic on
> >>> a link, and this is punishing a single tcp
> > Dave: it won't just punish a single TCP, all protocols that react to
> > XMIT_CN will share similar fate.
> 
> What protocols in the kernel do and don't? was the crux of this question.
> 

AFAIK that only tcp cares a bit, or seems to.

But not that much, since it continues to send packets.

Thats because tcp_transmit_skb() changes the NET_XMIT_CN status to plain
NET_XMIT_SUCCESS.

My long term plan is to reduce number of skbs queued in Qdisc for TCP
stack, to reduce RTT (removing the artificial RTT bias because of local
queues)

> I'm not objecting to the idea, it's clever, as I said. I'm thinking I'll
> apply it to cerowrt's next build and see what happens, if this
> will apply against 3.3. Or maybe the ns3 model. Or both.

A router will have no use of this feature, not sure you need to spend
time trying this ;)
