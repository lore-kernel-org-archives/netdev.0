From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: qdisc running
Date: Mon, 20 Oct 2014 18:17:47 -0400
Message-ID: <54458A0B.2010409@mojatatu.com>
References: <54440FFA.40307@mojatatu.com> <20141020181756.2c8f33b9@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john Fastabend <john.r.fastabend@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	eric Dumazet <edumazet@google.com>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:40579 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633AbaJTWRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 18:17:50 -0400
Received: by mail-ig0-f176.google.com with SMTP id hn15so183365igb.9
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 15:17:49 -0700 (PDT)
In-Reply-To: <20141020181756.2c8f33b9@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/14 12:17, Jesper Dangaard Brouer wrote:
>
> On Sun, 19 Oct 2014 15:24:42 -0400 Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>

> I guess it is good for our recent dequeue batching.

It is i think ;->

> But I think/hope we
> can come up with a scheme that does not requires 6 lock/unlock
> operations (as illustrated on slide 9).
>

To be clear:
2 locks + 2 unlock and 2 atomic ops.


> John and I have talked about doing a lockless qdisc, but maintaining
> this __QDISC___STATE_RUNNING in a lockless scenario, would cost us
> extra atomic ops...
>

In the animation this __QDISC___STATE_RUNNING is shown as "occupied"
flag. It is like someone is in the toilet and you cant come in;->
They have to finish dropping the packages into the toilet^Whardware ;->
If it is occupied, you put your package outside and go.

> Are we still sure, that this model of only allowing a single CPU in the
> dequeue path, is still the best solution?

For sure it is the best if you want to batch. Look at that last orange
guy picking all the packages (busylock.swf). This is where all the
batching would  happen.

>(The TXQ lock should already
> protect several CPUs in this code path).


Note:
Maybe for the orange guy (the dequeur) the tx lock could
be avoided? Double check the code. Important to note under
busy period contention is reduced to :
1 lock + 1 unlock + 2 atomic ops for N-1 CPUs.
The orange guy on the other hand is doing 2 lock/unlock.


> I can see that you really needed the budget/fairness in the dequeue
> loop, that we recently mangled with.
>

Yes, fairness is needed so the orange guy doesnt spend all his cycles
doing all the work (that was the basis of my presentation); unless
that is not an issue and the scheduler would move things away from
that cpu.


> What tool do I use to play these SWF files? (I tried VLC but no luck).
>

Firefox should work fine.

cheers,
jamal
