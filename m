From: Jim Gettys <jg@freedesktop.org>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Thu, 12 Jul 2012 12:54:50 -0400
Message-ID: <4FFF015A.5010809@freedesktop.org>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	<1340945457.29822.7.camel@edumazet-glaptop>
	<1341396687.2583.1757.camel@edumazet-glaptop>
	<20120709.000834.1182150057463599677.davem@davemloft.net>
	<1341845722.3265.3065.camel@edumazet-glaptop>
	<1341933215.3265.5476.camel@edumazet-glaptop>
	<CABrhC0=Ls7G-noW1cjsyiF+G5v9f9R=bi6JvrOoT5ZDQB=gSXg@mail.gmail.com>
	<1342100812.3265.8260.camel@edumazet-glaptop>
	<CABrhC0mONb3Ki5YYM1rfiBZnCKd2tYFvdYpuur-u3gDYRii1tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, codel@lists.bufferbloat.net,
	mattmathis@google.com, ncardwell@google.com,
	David Miller <davem@davemloft.net>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CABrhC0mONb3Ki5YYM1rfiBZnCKd2tYFvdYpuur-u3gDYRii1tw@mail.gmail.com>
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

On 07/12/2012 12:44 PM, John Heffner wrote:
> On Thu, Jul 12, 2012 at 9:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Thu, 2012-07-12 at 09:33 -0400, John Heffner wrote:
>>> One general question: why a per-connection limit?  I haven't been
>>> following the bufferbloat conversation closely so I may have missed
>>> some of the conversation.  But it seems that multiple connections will
>>> still cause longer queue times.
>> We already have a per-device limit, in qdisc.
>>
>> If you want to monitor several tcp sessions, I urge you use a controller
>> for that. Like codel or fq_codel.
>>
>> Experiments show that limiting to two TSO packets in qdisc per tcp flow
>> is enough to stop insane qdisc queueing, without impact on throughput
>> for people wanting fast tcp sessions.
>>
>> Thats not solving the more general problem of having 1000 competing
>> flows.
> Right, AQM (and probably some modifications to the congestion control)
> is the more general solution.
>
> I guess I'm just trying to justify in my mind that the case of a small
> number of local connections is worth handling in this special way.  It
> seems like a generally reasonable thing, but it's definitely not a
> general solution to minimizing latency.  One thing worth noting: on a
> system routing traffic, local connections may be at a disadvantage
> relative to connections being forwarded, sharing the same interface
> queue, if that queue is the bottleneck.

Kathy simulated CoDel across a pretty wide range of RTT's seen at the
edge of the network, and things behave pretty well.  She did say she
needed to think more and simulate the data center cases; haven't had a
chance to chat with her about that.  Of course, you can do some
experiments pretty easily yourself, and we'd love to see whatever
results you get.
                    - Jim


>
> Architecturally, the inconsistency between a local queue and a queue
> one hop away bothers me a bit, but it's something I can learn to live
> with if it really does improve a common case significantly. ;-)
>
> Thanks,
>   -John
> _______________________________________________
> Codel mailing list
> Codel@lists.bufferbloat.net
> https://lists.bufferbloat.net/listinfo/codel
