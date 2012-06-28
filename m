From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: report congestion
 notification at enqueue time
Date: Thu, 28 Jun 2012 19:47:54 -0400
Message-ID: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
References: <1340903237.13187.151.camel@edumazet-glaptop>
	<CAA93jw7agn2J6Hd7x22KWhENY5jqVjnk6uRr=3LJ5Anw7EgacQ@mail.gmail.com>
	<1340907151.13187.169.camel@edumazet-glaptop>
	<CAK6E8=dM0HNjjT=pDWzkBHs2Npi9foAnk1zxXdVLqBxA63dSqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Nandita Dukkipati <nanditad@google.com>, netdev <netdev@vger.kernel.org>,
	codel@lists.bufferbloat.net, Matt Mathis <mattmathis@google.com>,
	Neal Cardwell <ncardwell@google.com>, David Miller <davem@davemloft.net>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CAK6E8=dM0HNjjT=pDWzkBHs2Npi9foAnk1zxXdVLqBxA63dSqw@mail.gmail.com>
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

On Thu, Jun 28, 2012 at 6:56 PM, Yuchung Cheng <ycheng@google.com> wrote:
> On Thu, Jun 28, 2012 at 11:12 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
>> On Thu, 2012-06-28 at 10:51 -0700, Dave Taht wrote:
>>
>>> clever idea. A problem is there are other forms of network traffic on
>>> a link, and this is punishing a single tcp
> Dave: it won't just punish a single TCP, all protocols that react to
> XMIT_CN will share similar fate.

What protocols in the kernel do and don't? was the crux of this question.

I'm not objecting to the idea, it's clever, as I said. I'm thinking I'll
apply it to cerowrt's next build and see what happens, if this
will apply against 3.3. Or maybe the ns3 model. Or both.

As a segue...

I am still fond of gaining an ability to also throw congestion notifications
(who, where, and why) up to userspace via netlink. Having a viable
metric for things like mesh routing and multipath has been a age-old
quest of mine, and getting that data out could be a start towards it.

Another example is something that lives in userspace like uTP.

>
>>> stream that may not be the source of the problem in the first place,
>>> and basically putting it into double jeopardy.
>>>
>>
>> Why ? In fact this patch helps the tcp session being signaled (as it
>> will be anyway) at enqueue time, instead of having to react to packet
>> losses indications given (after RTT) by receiver.

I tend to think more in terms of routing packets rather than originating
them.

>> Avoiding losses help receiver to consume data without having to buffer
>> it into Out Of Order queue.
>>
>> So its not jeopardy, but early congestion notification without RTT
>> delay.

Well there is the birthday problem and hashing to the same queues.
the sims we have do some interesting things on new streams in slow
start sometimes. But don't have enough of a grip on it to talk about it
yet...

>>
>> NET_XMIT_CN is a soft signal, far more disruptive than a DROP.
> I don't read here: you mean far "less" disruptive in terms of performance?

I figured eric meant less.

>>
>>> I am curious as to how often an enqueue is actually dropping in the
>>> codel/fq_codel case, the hope was that there would be plenty of
>>> headroom under far more circumstances on this qdisc.
>>>
>>
>> "tc -s qdisc show dev eth0" can show you all the counts.
>>
>> We never drop a packet at enqueue time, unless you hit the emergency
>> limit (10240 packets for fq_codel). When you reach this limit, you are
>> under trouble.

In my own tests with artificial streams that set but don't respect ecn,
I hit limit easily. But that's the subject of another thread on the codel l=
ist,
and a different problem entirely. I just am not testing at > 1GigE
speeds and I know you guys are. I worry about behaviors above 10GigE,
and here too, the NET_XMIT_CN idea seems like a good idea.

so, applause. new idea on top of fair queue-ing + codel. cool. So many
hard problems seem to be getting tractable!

-- =

Dave T=E4ht
http://www.bufferbloat.net/projects/cerowrt/wiki - "3.3.8-6 is out
with fq_codel!"
