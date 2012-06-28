From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] fq_codel: report congestion notification at
 enqueue time
Date: Thu, 28 Jun 2012 15:56:46 -0700
Message-ID: <CAK6E8=dM0HNjjT=pDWzkBHs2Npi9foAnk1zxXdVLqBxA63dSqw@mail.gmail.com>
References: <1340903237.13187.151.camel@edumazet-glaptop> <CAA93jw7agn2J6Hd7x22KWhENY5jqVjnk6uRr=3LJ5Anw7EgacQ@mail.gmail.com>
 <1340907151.13187.169.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dave Taht <dave.taht@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, codel@lists.bufferbloat.net,
	Tom Herbert <therbert@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:56674 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801Ab2F1W5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 18:57:07 -0400
Received: by obbuo13 with SMTP id uo13so3668228obb.19
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 15:57:06 -0700 (PDT)
In-Reply-To: <1340907151.13187.169.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 28, 2012 at 11:12 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-06-28 at 10:51 -0700, Dave Taht wrote:
>
>> clever idea. A problem is there are other forms of network traffic on
>> a link, and this is punishing a single tcp
Dave: it won't just punish a single TCP, all protocols that react to
XMIT_CN will share similar fate.

>> stream that may not be the source of the problem in the first place,
>> and basically putting it into double jeopardy.
>>
>
> Why ? In fact this patch helps the tcp session being signaled (as it
> will be anyway) at enqueue time, instead of having to react to packet
> losses indications given (after RTT) by receiver.
>
> Avoiding losses help receiver to consume data without having to buffer
> it into Out Of Order queue.
>
> So its not jeopardy, but early congestion notification without RTT
> delay.
>
> NET_XMIT_CN is a soft signal, far more disruptive than a DROP.
I don't read here: you mean far "less" disruptive in terms of performance?

>
>> I am curious as to how often an enqueue is actually dropping in the
>> codel/fq_codel case, the hope was that there would be plenty of
>> headroom under far more circumstances on this qdisc.
>>
>
> "tc -s qdisc show dev eth0" can show you all the counts.
>
> We never drop a packet at enqueue time, unless you hit the emergency
> limit (10240 packets for fq_codel). When you reach this limit, you are
> under trouble.

Another nice feature is to resume TCP xmit operation at when the skb
hits the wire.
My hutch is that Eric is working on this too.
>
>
>
